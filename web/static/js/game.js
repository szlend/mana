import {Socket} from "phoenix"

if (window.location.pathname.startsWith('/games')) {
  let socket = new Socket("/socket", {params: {token: window.userToken}})
  socket.connect()

  let channel = socket.channel("game:lobby")
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.push("create", {name: "my game"})
    .receive("ok", (name) => console.log("created game: ", name))
    .receive("error", (msg) => console.log(msg))
}
