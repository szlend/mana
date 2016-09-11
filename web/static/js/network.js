import {Socket} from "phoenix"

export default class Network {
  constructor(game, token) {
    this.game = game
    this.token = token
    this.socket = new Socket("/socket", {params: {token}})
    this.channel = this.socket.channel("game")
  }

  connect() {
    this.game.onRequestGrid = this.onRequestGrid.bind(this)
    this.game.onTileClick = this.onTileClick.bind(this)
    this.socket.connect()
    this.channel.join()
      .receive("ok", this.onGameJoin.bind(this))
      .receive("error", this.onGameJoinError.bind(this))
  }

  onGameJoin(data) {
    console.log(`Joined game with users:`, data.users)
    if (data.last_move) {
      this.game.setCameraTileCoordinates(data.last_move.x, data.last_move.y)
    } else {
      this.game.setCameraTileCoordinates(0, 0)
    }
  }

  onGameJoinError(resp) {
    console.log(`Failed to join game, response:`, resp)
  }

  onGridJoin(data) {
    console.log(`Joined grid (${data.x}, ${data.y})`, data)
    this.game.addMoves(data.moves)
    this.game.addMines(data.mines)
  }

  onGridJoinError(resp) {
    console.log(`Failed to join grid, response:`, resp)
  }

  onTileReveal(data) {
    this.game.addMoves(data.moves)
  }

  onRequestGrid(x, y) {
    const channel = this.socket.channel(`grid:${x}:${y}`)
    channel.join()
      .receive("ok", this.onGridJoin.bind(this))
      .receive("error", this.onGridJoinError.bind(this))
    channel.on("reveal", this.onTileReveal.bind(this))
  }

  onTileClick(x, y) {
    this.channel.push("reveal", {x: x, y: y})
  }
}
