import {Socket} from "phoenix"

const token = window.userToken
const div = document.getElementById("game")

if (div) {
  let canvas = document.getElementById('game')
  let context = canvas.getContext('2d')

  let isScrolling = false
  let isClick = true

  const tileSize = 24
  const sizeX = canvas.width / tileSize
  const sizeY = canvas.height / tileSize

  let cameraX = 0
  let cameraY = 0

  let touchX = null
  let touchY = null

  let mines = []

  document.addEventListener('mousedown', mouseDown, false)
  document.addEventListener('mouseup', mouseUp, false)

  canvas.addEventListener('click', canvasClick, false)
  canvas.addEventListener('mousemove', mouseMove, false)
  canvas.addEventListener("touchmove", touchMove, false)

  render()

  function render() {
    // const width = canvas.parentElement.getBoundingClientRect().width
    // const height = window.innerHeight - canvas.offsetTop
    // const size = Math.min(width, height)
    // console.log(width, height, size)
    //
    // canvas.width = size
    // canvas.height = size

    context.clearRect(0, 0, canvas.width, canvas.height)

    const renderOffsetX = -tileSize + (cameraX % tileSize)
    const renderOffsetY = -tileSize + (cameraY % tileSize)

    context.beginPath()
    context.strokeStyle = '#666';
    for (let y = 0; y < canvas.height; y++) {
      for (let x = 0; x < canvas.width; x++) {
        context.rect(renderOffsetX + (x * tileSize), renderOffsetY + (y * tileSize), tileSize, tileSize)
      }
    }

    for (let [mineX, mineY] of mines) {
      const x = cameraX + mineX * tileSize
      const y = cameraY + mineY * tileSize

      context.fillRect(x, y, tileSize, tileSize)
      // console.log(x, y)
    }

    context.stroke()

    document.getElementById('game-x').innerText = `X: ${-cameraX}`
    document.getElementById('game-y').innerText = `Y: ${cameraY}`

    requestAnimationFrame(render)
  }

  function updateGrid(x, y) {
    cameraX += x - touchX
    cameraY += y - touchY
    touchX = x
    touchY = y
  }

  function touchMove(e) {
    const x = Math.round(e.touches[0].clientX)
    const y = Math.round(e.touches[0].clientY)
    updateGrid(x, y)
  }

  function mouseDown(e) {
    isScrolling = true
    touchX = e.clientX
    touchY = e.clientY
  }
  function mouseUp() {
    isScrolling = false
  }

  function mouseMove(e) {
    if (isScrolling) {
      updateGrid(e.clientX, e.clientY)
      isClick = false
    }
  }

  function canvasClick(e) {
    if (isClick) {
      console.log(tileCoordinates(e.offsetX, e.offsetY))
    }
    isClick = true
  }

  function tileCoordinates(mouseX, mouseY) {
    const x = Math.floor((-cameraX + mouseX) / tileSize)
    const y = Math.floor((cameraY - mouseY) / tileSize)
    return [x, y]
  }

  // Here comes dat channel stuff

  const name = div.dataset.name
  const socket = new Socket("/socket", {params: {token}})
  socket.connect()

  const game = socket.channel(`game:${name}`)
  game.join()
    // Continue here. Use jQuery approach!!!11enajst
    .receive("error", resp => console.log(`Failed to join game "${name}"`, resp))
    .receive("ok", (users) => {
      console.log(`Joined game "${name}"`, users)

      game.push("mines", {x: [-20, 20], y: [-20, 20]})
        .receive("ok", (payload) => {
          console.log("Mines", payload.mines)
          mines = payload.mines
        })
    })

  game.on("mines", mines => {
    console.log(mines)
  })
}
