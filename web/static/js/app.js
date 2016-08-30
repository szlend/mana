import "babel-polyfill"
import "phoenix_html"
import Game from "./game"
import Network from "./network"

if (window.gamePage) {
  const token = window.userToken
  const canvas = document.getElementById("game")
  const game = new Game(canvas, {scale: window.devicePixelRatio})
  const network = new Network(game, token)
  network.connect()
  game.run()
  window.teleport = game.setCameraTilePosition.bind(game)
}
