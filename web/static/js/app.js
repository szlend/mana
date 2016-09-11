import "babel-polyfill"
import "phoenix_html"
import Game from "./game"
import Network from "./network"

if (window.gamePage) {
  const canvas = document.getElementById("game")
  const token = canvas.dataset.token
  const size = parseInt(canvas.dataset.size)
  const game = new Game(canvas, size, {scale: window.devicePixelRatio})
  const network = new Network(game, token)
  network.connect()
  game.run()
  window.teleport = game.setCameraTileCoordinates.bind(game)
}
