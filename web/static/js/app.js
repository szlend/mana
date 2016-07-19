import "phoenix_html"
import {Socket} from "phoenix"
import Game from "./game"

const token = window.userToken
const div = document.getElementById("game")

if (div) {
  // Game stuff
  const canvas = document.getElementById('game')
  const game = new Game(canvas)

  game.onCameraMove = function(cameraX, cameraY) {
    document.getElementById('game-x').innerText = `X: ${cameraX}`
    document.getElementById('game-y').innerText = `Y: ${cameraY}`
  }

  game.onTileClick = function(tileX, tileY) {
    console.log(`Clicked on tile (${tileX}, ${tileY})`)
  }

  game.run()
  game.onCameraMove(game.cameraX, game.cameraY)

  // Channel stuff
  const name = div.dataset.name
  const socket = new Socket("/socket", {params: {token}})
  socket.connect()

  const channel = socket.channel(`game:${name}`)
  channel.join()
    .receive("error", resp => console.log(`Failed to join game "${name}"`, resp))
    .receive("ok", (users) => {
      console.log(`Joined game "${name}"`, users)
      channel.push("mines", {x: [-20, 20], y: [-20, 20]})
        .receive("ok", onMinesReceived)
    })

  function onMinesReceived(data) {
    console.log("Received mines: ", data.mines)
    game.mines = data.mines
  }
}
