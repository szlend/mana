let canvas = document.getElementById('game')
let context = canvas.getContext('2d')

const RIGHT_KEY_CODE = 39
const LEFT_KEY_CODE = 37
const UP_KEY_CODE = 38
const DOWN_KEY_CODE = 40

let keysPressed = {}

const tileSize = 24
const sizeX = canvas.width / tileSize
const sizeY = canvas.height / tileSize

let mapX = 0
let mapY = 0

let touchX = null
let touchY = null

document.addEventListener('keydown', keyDown, false)
document.addEventListener('keyup', keyUp, false)
canvas.addEventListener("touchmove", handleMove, false)

render()
setInterval(update, 1000 / 120)

function update() {
  if (keysPressed[RIGHT_KEY_CODE]) mapX = mapX + 2
  if (keysPressed[LEFT_KEY_CODE]) mapX = mapX - 2
  if (keysPressed[UP_KEY_CODE]) mapY = mapY - 2
  if (keysPressed[DOWN_KEY_CODE]) mapY = mapY + 2
}

function render() {
  // console.log(mapX, mapY)
  context.clearRect(0, 0, canvas.width, canvas.height)

  const offsetX = -tileSize + (mapX % tileSize)
  const offsetY = -tileSize + (mapY % tileSize)

  context.beginPath()
  for (let y = 0; y < canvas.height; y++) {
    for (let x = 0; x < canvas.width; x++) {
      context.rect(offsetX + (x * tileSize), offsetY + (y * tileSize), tileSize, tileSize)
    }
  }
  context.stroke()

  requestAnimationFrame(render)
}

function keyDown(e) {
  keysPressed[e.keyCode] = true
}

function keyUp(e) {
  keysPressed[e.keyCode] = false
}

function handleMove(e) {
  const prevTouchX = touchX
  const prevTouchY = touchY
  touchX = e.touches[0].clientX
  touchY = e.touches[0].clientY
  if (prevTouchX !== null) {
    mapX += touchX - prevTouchX
    mapY += touchY - prevTouchY
  }
}


// import {Socket} from "phoenix"
//
// const token = window.userToken
// const div = document.getElementById("game")
//
// if (div) {
//   const name = div.dataset.name
//   const socket = new Socket("/socket", {params: {token}})
//   socket.connect()
//
//   const game = socket.channel(`game:${name}`)
//   game.join()
//     // Continue here. Use jQuery approach!!!11enajst
//     .receive("ok", (users) => console.log(`Joined game ${name}`, users))
//     .receive("error", resp => console.log(`Failed to join game ${name}`, resp))
// }
