import "babel-polyfill"
import "phoenix_html"
import Game from "./game"
import Network from "./network"

if (window.gamePage) {
  const token = window.userToken
  const canvas = document.getElementById("game")
  const gameName = canvas.dataset.name
  const game = new Game(canvas, {scale: window.devicePixelRatio})
  const network = new Network(game, gameName, token)
  network.connect()
  game.run()
}
