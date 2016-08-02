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

  game.onRequestGrid = function(fromX, toX, fromY, toY) {
    channel.push("mines", {x: [fromX, toX], y: [fromY, toY]})
      .receive("ok", onReceiveMines)
  }

  game.onTileClick = function(tileX, tileY) {
    const ul = document.getElementById("game-moves")
    let li = document.createElement("li")
    li.innerText = `Clicked on tile (${tileX}, ${tileY})`
    ul.insertBefore(li, ul.firstChild)

    channel.push("reveal", {x: tileX, y: tileY})
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

  channel.on("reveal", onTileReveal)

  function onGameJoin(data) {
    console.log(`Joined game "${name}", with users:`, data.users)

    const ul = document.getElementById("game-users")
    for (const user of data.users) {
      let li = document.createElement("li")
      li.innerText = user
      ul.insertBefore(li, ul.firstChild)
    }

    channel.push("mines", {x: [-20, 20], y: [-20, 20]})
      .receive("ok", onReceiveMines)
  }

  function onReceiveMines(data) {
    game.mines = data.mines
  }

  function onTileReveal(data) {
    game.moves.push(data.move)
  }
}
