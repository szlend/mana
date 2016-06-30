import {Socket} from "phoenix"

const token = window.userToken
const div = document.getElementById("game")

if (div) {
  const name = div.dataset.name
  const socket = new Socket("/socket", {params: {token}})
  socket.connect()

  const game = socket.channel(`game:${name}`)
  game.join()
    .receive("ok", () => console.log(`Joined game ${name}`))
    .receive("error", resp => console.log(`Failed to join game ${name}`, resp))
}
