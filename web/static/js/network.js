import {Socket} from "phoenix"

export default class Network {
  constructor(game, token, name, playerDivs, scoreDivs) {
    this.game = game
    this.token = token
    this.name = name
    this.socket = new Socket("/socket", {params: {token}})
    this.channel = this.socket.channel("game", {name: this.name})
    this.grids = {}
    this.score = 0
    this.scores = {}
    this.playerDivs = playerDivs
    this.scoreDivs = scoreDivs
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
      console.log(data)
      this.score = data.score
      this.scores = data.scores

      if (data.last_move) {
        this.game.setCameraTileCoordinates(data.last_move.x, data.last_move.y)
      } else {
        this.game.setCameraTileCoordinates(0, 0)
      }

      this.updateScores()
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
    this.score = data.score
    this.updateScores()
  }

  onScoresUpdate(data) {
    this.scores = data.scores
    this.updateScores()
  }

  updateScores() {
    let ownEntry = null
    if (this.scores.length === 0) {
      ownEntry = this.scores.push({name: this.name, score: this.score})
    } else {
      ownEntry = this.scores.find(entry => entry.name === this.name)
      ownEntry = ownEntry || this.scores[this.scores.length - 1]
    }

    for (const i in this.scores) {
      const entry = this.scores[i]
      this.playerDivs[i].innerText = entry.name
      this.scoreDivs[i].innerText = entry.score.toString()
      this.playerDivs[i].style.color = entry.name === this.name ? "yellow" : "white"
      this.scoreDivs[i].style.color = entry.name === this.name ? "yellow" : "white"
    }
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
