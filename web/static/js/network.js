import {Socket} from "phoenix"

export default class Network {
  constructor(game, token, name) {
    this.game = game
    this.token = token
    this.name = name
    this.socket = new Socket("/socket", {params: {token}})
    this.channel = this.socket.channel("game", {name: this.name})
    this.grids = {}
    this.firstJoin = true
  }

  connect() {
    this.game.onRequestGrid = this.onRequestGrid.bind(this)
    this.game.onDisposeGrid = this.onDisposeGrid.bind(this)
    this.game.onTileClick = this.onTileClick.bind(this)
    this.socket.connect()
    this.channel.join()
      .receive("ok", this.onGameJoin.bind(this))
      .receive("error", this.onGameJoinError.bind(this))
    this.channel.on("score", this.onScoreUpdate.bind(this))
    this.channel.on("scores", this.onScoresUpdate.bind(this))
  }

  onGameJoin(data) {
    console.log("Joined game", data)
    if (this.firstJoin) {
      this.game.run()
      this.firstJoin = false

      if (data.last_move) {
        this.game.setCameraTileCoordinates(data.last_move.x, data.last_move.y)
      } else {
        this.game.setCameraTileCoordinates(0, 0)
      }
    }
  }

  onGameJoinError(resp) {
    console.log("Failed to join game, response:", resp)
    if (this.firstJoin && resp.message) {
      const message = encodeURIComponent(resp.message)
      window.location = `/error?message=${message}`
    }
  }

  onScoreUpdate(data) {
    console.log("Own score updated:", data.score)
  }

  onScoresUpdate(data) {
    console.log("Top scores updated:", data.scores)
  }

  onGridJoin(data) {
    console.log(`Joined grid (${data.x}, ${data.y})`, data)
    this.game.addMines(data.mines)
    this.game.addMoves(data.moves)
  }

  onGridJoinError(resp) {
    console.log("Failed to join grid, response:", resp)
  }

  onGridLeave(grid) {
    console.log(`Left grid (${grid.x}, ${grid.y})`)
    this.game.cleanupGrid(grid.x, grid.y)
  }

  onTileReveal(data) {
    this.game.addMoves(data.moves)
  }

  onRequestGrid(x, y) {
    const name = `grid:${x}:${y}`
    if (!this.grids[name]) {
      const channel = this.socket.channel(name)
      channel.join()
        .receive("ok", this.onGridJoin.bind(this))
        .receive("error", this.onGridJoinError.bind(this))
      channel.onClose(this.onGridLeave.bind(this, {x: x, y: y}))
      channel.onError(this.onGridLeave.bind(this, {x: x, y: y}))
      channel.on("reveal", this.onTileReveal.bind(this))
      this.grids[name] = channel
    }
  }

  onDisposeGrid(x, y) {
    const name = `grid:${x}:${y}`
    if (this.grids[name]) {
      this.grids[name].leave()
      delete this.grids[name]
    }
  }

  onTileClick(x, y) {
    this.channel.push("reveal", {x: x, y: y})
  }
}
