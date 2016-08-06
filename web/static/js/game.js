export default class Game {
  constructor(canvas) {
    // HTML canvas element and context
    this.canvas = canvas
    this.context = canvas.getContext("2d")

    // Tile size in pixels
    this.tileSize = 24

    // Camera pixel position on the map
    this.cameraX = 0
    this.cameraY = 0

    // Input state
    this.isScrolling = false  // determine if mouse movement should move the camera
    this.isClick = true       // determine if it's a click or a drag

    // Last touch pixel position on canvas
    this.touchX = 0
    this.touchY = 0

    // Global list of mines (localize later)
    this.mines = []
    this.moves = []

    // Game running state
    this.running = false

    // Callbacks
    this.onCameraMove = null
    this.onRequestGrid = null
    this.onTileClick = null

    // Callback debounce
    this.onRequestGridTime = 0
  }

  run() {
    if (this.running) throw "Game is already running."
    this.running = true

    // Register global events
    document.addEventListener("mousedown", this.handleMouseDown.bind(this), false)
    document.addEventListener("mouseup", this.handleMouseUp.bind(this), false)

    // Register canvas events
    this.canvas.addEventListener("mousemove", this.handleMouseMove.bind(this), false)
    this.canvas.addEventListener("touchmove", this.handleTouchMove.bind(this), false)
    this.canvas.addEventListener("click", this.handleClick.bind(this), false)

    // Request starting grid
    const [x, y] = this.getCameraTilePosition()
    if (this.onRequestGrid) this.onRequestGrid(x - 25, y - 25, 50, 50)

    // Start rendering
    this.render()
  }

  render() {
    const canvas = this.canvas
    const context = this.context
    const tileSize = this.tileSize
    const cameraX = this.cameraX
    const cameraY = this.cameraY

    // Clear screen
    context.clearRect(0, 0, canvas.width, canvas.height)

    // Get the offset of a part of the tile to start rendering with
    const renderOffsetX = -tileSize + (cameraX % tileSize)
    const renderOffsetY = -tileSize + (cameraY % tileSize)

    // Render mines
    context.fillStyle = "black"
    for (const [mineTileX, mineTileY] of this.mines) {
      const mineScreenX = cameraX + mineTileX * tileSize
      const mineScreenY = cameraY + mineTileY * tileSize
      context.fillRect(mineScreenX, mineScreenY, tileSize, tileSize)
    }

    // Render exploded mines
    context.fillStyle = "black"
    context.font = `${tileSize}px sans-serif`
    context.textAlign = "center"
    context.textBaseline = "middle"
    for (const [moveX, moveY] of this.getMineMoves()) {
      const moveScreenX = cameraX + moveX * tileSize
      const moveScreenY = cameraY + moveY * tileSize
      const numberX = moveScreenX + Math.floor(tileSize / 2)
      const numberY = moveScreenY + Math.floor(tileSize / 2)
      context.fillText("💥", numberX, numberY)
    }

    // Render empty tiles
    context.fillStyle = "lightgray"
    for (const [moveX, moveY] of this.getEmptyMoves()) {
      const moveScreenX = cameraX + moveX * tileSize
      const moveScreenY = cameraY + moveY * tileSize
      context.fillRect(moveScreenX, moveScreenY, tileSize, tileSize)
    }

    // Render numbered tiles
    context.fillStyle = "black"
    context.font = `${tileSize}px sans-serif`
    context.textAlign = "center"
    context.textBaseline = "middle"
    for (const [moveX, moveY, moveNumber] of this.getNumberMoves()) {
      const moveScreenX = cameraX + moveX * tileSize
      const moveScreenY = cameraY + moveY * tileSize
      const numberX = moveScreenX + Math.floor(tileSize / 2)
      const numberY = moveScreenY + Math.floor(tileSize / 2)
      context.fillText(moveNumber.toString(), numberX, numberY)
    }

    // Render grid
    context.beginPath()
    context.strokeStyle = "#666"
    for (let y = 0; y < canvas.height; y++) {
      for (let x = 0; x < canvas.width; x++) {
        const rectScreenX = renderOffsetX + (x * tileSize)
        const rectScreenY = renderOffsetY + (y * tileSize)
        context.rect(rectScreenX, rectScreenY, tileSize, tileSize)
      }
    }
    context.stroke()

    requestAnimationFrame(this.render.bind(this))
  }

  getMineMoves() {
    return this.moves.filter(move => move[2] === 9)
  }

  getEmptyMoves() {
    return this.moves.filter(move => move[2] === 0)
  }

  getNumberMoves() {
    return this.moves.filter(move => move[2] > 0 && move[2] < 9)
  }

  getCameraPosition() {
    return [-this.cameraX, this.cameraY]
  }

  getCameraTilePosition() {
    const [cameraX, cameraY] = this.getCameraPosition()
    const x = Math.floor(cameraX / this.tileSize)
    const y = Math.floor(-cameraY / this.tileSize)
    return [x, y]
  }

  getTilePosition(pixelX, pixelY) {
    const [cameraX, cameraY] = this.getCameraPosition()
    const x = Math.floor((cameraX + pixelX) / this.tileSize)
    const y = Math.floor((-cameraY + pixelY) / this.tileSize)
    return [x, y]
  }

  moveCamera(touchX, touchY) {
    this.cameraX += touchX - this.touchX
    this.cameraY += touchY - this.touchY
    this.touchX = touchX
    this.touchY = touchY

    if (this.onCameraMove) this.onCameraMove(this.cameraX, this.cameraY)
    if (this.onRequestGrid && this.onRequestGridTime + 500 < Date.now()) {
      this.onRequestGridTime = Date.now()
      const [x, y] = this.getCameraTilePosition()
      this.onRequestGrid(x - 25, y - 25, 50, 50)
    }
  }

  // Event handlers

  handleMouseDown(event) {
    [this.touchX, this.touchY] = [event.clientX, event.clientY]
    this.isScrolling = true
  }

  handleMouseUp() {
    this.isScrolling = false
  }

  handleMouseMove(event) {
    if (this.isScrolling) {
      this.moveCamera(event.clientX, event.clientY)
      this.isClick = false
    }
  }

  handleTouchMove(event) {
    const x = Math.round(event.touches[0].clientX)
    const y = Math.round(event.touches[0].clientY)
    this.moveCamera(x, y)
  }

  handleClick(event) {
    if (this.isClick && this.onTileClick) {
      const [tileX, tileY] = this.getTilePosition(event.offsetX, event.offsetY)
      this.onTileClick(tileX, tileY)
    }
    this.isClick = true
  }
}
