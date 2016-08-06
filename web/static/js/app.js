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

  game.onRequestGrid = function(x, y, w, h) {
    channel.push("mines", {x: x, y: y, w: w, h: h})
      .receive("ok", onReceiveMines)

    channel.push("moves", {x: x, y: y, w: w, h: h})
      .receive("ok", onReceiveMoves)
  }

  game.onTileClick = function(x, y) {
    const ul = document.getElementById("game-moves")
    let li = document.createElement("li")
    li.innerText = `Clicked on tile (${x}, ${y})`
    ul.insertBefore(li, ul.firstChild)

    channel.push("reveal", {x: x, y: y})
  }

  // Channel stuff
  const name = div.dataset.name
  const socket = new Socket("/socket", {params: {token}})
  socket.connect()

  const channel = socket.channel(`game:${name}`)
  channel.join()
    .receive("error", resp => console.log(`Failed to join game "${name}", response:`, resp))
    .receive("ok", onGameJoin)

  channel.on("reveal", onTileReveal)

  game.run()
  game.onCameraMove(game.cameraX, game.cameraY)

  function onGameJoin(data) {
    console.log(`Joined game "${name}", with users:`, data.users)

    const ul = document.getElementById("game-users")
    for (const user of data.users) {
      let li = document.createElement("li")
      li.innerText = user
      ul.insertBefore(li, ul.firstChild)
    }
  }

  function onReceiveMines(data) {
    console.log(data)
    game.mines = data.mines
  }

  function onReceiveMoves(data) {
    console.log(data.moves)
    game.moves = data.moves
  }

  function onTileReveal(data) {
    console.log(data.moves)
    game.moves = game.moves.concat(data.moves)
  }
}
