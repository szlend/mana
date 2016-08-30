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
      .receive("error", this.onGameJoinError.bind(this))
      .receive("ok", this.onGameJoin.bind(this))
    this.channel.on("reveal", this.onTileReveal.bind(this))
  }

  onGameJoin(data) {
    console.log(`Joined game with users:`, data.users)
    if (data.last_move) {
      this.game.setCameraTilePosition(data.last_move.x, data.last_move.y)
    }
  }

  onGameJoinError(resp) {
    console.log(`Failed to join game, response:`, resp)
  }

  onReceiveMines(data) {
    this.game.setMines(data.mines)
  }

  onReceiveMoves(data) {
    this.game.setMoves(data.moves)
  }

  onTileReveal(data) {
    this.game.addMoves(data.moves)
  }

  onRequestGrid(x, y, w, h) {
    this.channel
      .push("mines", {x: x, y: y, w: w, h: h})
      .receive("ok", this.onReceiveMines.bind(this))
    this.channel
      .push("moves", {x: x, y: y, w: w, h: h})
      .receive("ok", this.onReceiveMoves.bind(this))
  }

  onTileClick(x, y) {
    this.channel.push("reveal", {x: x, y: y})
  }
}
