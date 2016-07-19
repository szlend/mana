import "phoenix_html"
import {Socket} from "phoenix"
import Game from "./game"

const token = window.userToken
const div = document.getElementById("game")

if (div) {
  // Game stuff
  const canvas = document.getElementById("game")
  const game = new Game(canvas)

  game.onCameraMove = function(cameraX, cameraY) {
    document.getElementById("game-x").innerText = `X: ${cameraX}`
    document.getElementById("game-y").innerText = `Y: ${cameraY}`
  }

  game.onTileClick = function(tileX, tileY) {
    const moves = document.getElementById("game-moves")
    let li = document.createElement("li")
    li.innerText = `Clicked on tile (${tileX}, ${tileY})`
    moves.insertBefore(li, moves.firstChild);
  }

  game.run()
  game.onCameraMove(game.cameraX, game.cameraY)

  // Channel stuff
  const name = div.dataset.name
  const socket = new Socket("/socket", {params: {token}})
  socket.connect()

  const channel = socket.channel(`game:${name}`)
  channel.join()
    .receive("error", resp => console.log(`Failed to join game "${name}", response:`, resp))
    .receive("ok", onGameJoin)

  function onGameJoin(data) {
    console.log(`Joined game "${name}", with users:`, data.users)
    channel.push("mines", {x: [-20, 20], y: [-20, 20]})
      .receive("ok", onReceiveMines)
  }

  function onReceiveMines(data) {
    console.log("Received mines:", data.mines)
    game.mines = data.mines
  }
}
