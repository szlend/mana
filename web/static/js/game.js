import PIXI from "pixi.js"
import Rx from "rx-lite-dom-events"

export default class Engine {
  constructor(canvas, options = {}) {
    this.renderer = PIXI.autoDetectRenderer(0, 0, {view: canvas, backgroundColor: 0xFFFFFF})
    this.scene = new PIXI.Container()
    this.background = new PIXI.Container()
    this.map = new PIXI.ParticleContainer()
    this.grid = {}

    this.scene.addChild(this.background)
    this.scene.addChild(this.map)

    this.scale = options.scale || 1
    this.width = 0
    this.height = 0
    this.tileSize = 32 * this.scale

    // Tileset texture info
    this.textureSize = 128
    this.textureScale = 1 / (this.textureSize / this.tileSize)

    // Camera pixel position on the map (top-left)
    this.cameraX = 0
    this.cameraY = 0

    // Global list of mines (localize later)
    this.mines = []
    this.moves = []

    // Game running state
    this.running = false

    // Should the game re-render
    this.update = true

    // Grid size for streaming new moves
    this.requestSize = 0

    // Last position we streamed in new moves
    this.lastGridRequest = [this.cameraX, this.cameraY]

    // Event observers
    this.mouseDown = Rx.DOM.mousedown(this.renderer.view)
    this.mouseUp = Rx.DOM.mouseup(this.renderer.view)
    this.mouseMove = Rx.DOM.mousemove(this.renderer.view)
    this.mouseOut = Rx.DOM.mouseout(this.renderer.view)
    this.touchStart = Rx.DOM.touchstart(this.renderer.view)
    this.touchEnd = Rx.DOM.touchend(this.renderer.view)
    this.touchMove = Rx.DOM.touchmove(this.renderer.view)
    this.mouseScroll = Rx.Observable.fromEvent(this.renderer.view, "mousewheel")
    this.cameraMove = this.cameraMoveObserver()
    this.tileClick = this.tileClickObserver()

    // Callbacks
    this.onCameraMove = () => {}
    this.onRequestGrid = () => {}
    this.onTileClick = () => {}
  }

  run() {
    if (this.running) throw "Game is already running."
    this.running = true

    // Set tiles
    this.tiles = this.loadTiles({
      unclear: [  0,   0],
      flag:    [128,   0],
      mine:    [256,   0],
      empty:   [384,   0],
      [1]:     [  0, 128],
      [2]:     [128, 128],
      [3]:     [256, 128],
      [4]:     [384, 128],
      [5]:     [  0, 256],
      [6]:     [128, 256],
      [7]:     [256, 256],
      [8]:     [384, 256]
    })

    // Set background
    this.backgroundSprite = new PIXI.extras.TilingSprite(this.tiles.unclear, 0, 0)
    this.backgroundSprite.scale.set(this.textureScale)
    this.background.addChild(this.backgroundSprite)

    // Subscribe to tile clicks
    this.tileClick.subscribe(([x, y]) => this.onTileClick(x, y))

    // Subscribe to camera movement
    this.cameraMove.subscribe(([x, y]) => this.updateCamera(x, y))

    // Request starting grid
    this.updateDimensions()
    this.setCameraTilePosition(0, 0)

    // Start rendering
    this.render()
  }

  render() {
    const render = this.render.bind(this)
    if (this.update || this.updateDimensions()) {
      this.translateMap()
      this.renderer.render(this.scene)
      this.update = false
    }
    requestAnimationFrame(render)
  }

  updateDimensions() {
    const view = this.renderer.view
    const width = view.clientWidth
    const height = view.clientHeight

    this.width = width * this.scale
    this.height = height * this.scale

    if (view.width !== this.width || view.height !== this.height) {
      this.renderer.resize(this.width, this.height)
      this.backgroundSprite.width = (this.width + 2 * this.tileSize) * this.scale
      this.backgroundSprite.height = (this.height + 2 * this.tileSize) * this.scale
      this.requestSize = 3 * Math.round(Math.max(this.width, this.height) / this.tileSize)
      return true
    } else {
      return false
    }
  }

  translateMap() {
    this.map.position.x = -this.cameraX
    this.map.position.y = this.cameraY
    this.backgroundSprite.tilePosition.x = -this.cameraX / this.textureScale
    this.backgroundSprite.tilePosition.y = this.cameraY / this.textureScale
  }

  cleanupGrid() {
    const [tileX, tileY] = this.getCameraTilePosition()
    for (const y in this.grid) {
      for (const x in this.grid[y]) {
        if (Math.abs(tileX - x) > this.requestSize || Math.abs(tileY - y) > this.requestSize) {
          this.map.removeChild(this.grid[y][x])
          delete this.grid[y][x]
        }
      }
    }
  }

  updateGridMines() {
    for (const [x, y] of this.mines) {
      this.grid[y] = this.grid[y] || {}
      this.grid[y][x] = this.grid[y][x] || new PIXI.Sprite(this.tiles.flag)
      this.grid[y][x].position.set(x * this.tileSize, -y * this.tileSize)
      this.grid[y][x].scale.set(this.textureScale)
      this.map.addChild(this.grid[y][x])
    }
    this.update = true
  }

  updateGridMoves() {
    for (const [x, y, move] of this.moves) {
      this.grid[y] = this.grid[y] || {}
      this.grid[y][x] = this.grid[y][x] || new PIXI.Sprite()
      this.grid[y][x].position.set(x * this.tileSize, -y * this.tileSize)
      this.grid[y][x].scale.set(this.textureScale)
      switch (move) {
        case 0:
          this.grid[y][x].texture = this.tiles.empty
          break
        case 9:
          this.grid[y][x].texture = this.tiles.mine
          break
        default:
          this.grid[y][x].texture = this.tiles[move]
          break
      }
      this.map.addChild(this.grid[y][x])
    }
    this.update = true
  }

  updateCamera(x, y) {
    this.cameraX = x
    this.cameraY = y
    this.update = true

    const [x1, y1] = this.getCameraTilePosition()
    const [x2, y2] = this.lastGridRequest
    if (Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2)) > this.requestSize / 3) {
      this.cleanupGrid()
      this.requestGrid()
    }

    this.onCameraMove(x, y)
  }

  setMines(mines) {
    this.mines = mines
    this.updateGridMines()
  }

  setMoves(moves) {
    this.moves = moves
    this.updateGridMoves()
  }

  addMoves(moves) {
    this.moves = this.moves.concat(moves)
    this.updateGridMoves()
  }

  getCameraTilePosition() {
    const x = Math.floor(this.cameraX / this.tileSize)
    const y = Math.floor(this.cameraY / this.tileSize)
    const midX = Math.round(this.width / this.tileSize / 2)
    const midY = Math.round(this.height / this.tileSize / 2)
    return [x + midX, y - midY]
  }

  setCameraTilePosition(x, y) {
    const midX = Math.round(this.width / 2)
    const midY = Math.round(this.height / 2)
    const pixelX = x * this.tileSize
    const pixelY = y * this.tileSize
    this.cameraX = pixelX - midX
    this.cameraY = pixelY + midY
    this.requestGrid()
  }

  getTilePosition(pixelX, pixelY) {
    const x = Math.floor((this.cameraX + (pixelX * this.scale)) / this.tileSize)
    const y = Math.ceil((this.cameraY - (pixelY * this.scale)) / this.tileSize)
    return [x, y]
  }

  requestGrid() {
    const [x, y] = this.getCameraTilePosition()
    const margin = Math.ceil(this.requestSize / 2)
    this.lastGridRequest = [x, y]
    this.onRequestGrid(x - margin, y - margin, this.requestSize, this.requestSize)
  }

  cameraMoveObserver() {
    const mouse = this.mouseDown.flatMap(downEvent => {
      const [cameraX, cameraY] = [this.cameraX, this.cameraY]
      return this.mouseMove
        .takeUntil(this.mouseUp)
        .takeUntil(this.mouseOut)
        .map(moveEvent => [
          cameraX + (downEvent.clientX - moveEvent.clientX) * this.scale,
          cameraY - (downEvent.clientY - moveEvent.clientY) * this.scale
        ])
    })

    const touch = this.touchStart.flatMap(startEvent => {
      const [cameraX, cameraY] = [this.cameraX, this.cameraY]
      return this.touchMove
        .takeUntil(this.touchEnd)
        .map(moveEvent => [
          cameraX + (startEvent.touches[0].clientX - moveEvent.touches[0].clientX) * this.scale,
          cameraY - (startEvent.touches[0].clientY - moveEvent.touches[0].clientY) * this.scale
        ])
    })

    const scroll = this.mouseScroll.map(event => [
      this.cameraX + event.deltaX,
      this.cameraY - event.deltaY
    ])

    return Rx.Observable.merge(mouse, touch, scroll)
  }

  tileClickObserver() {
    const dist = ([x1, y1], [x2, y2]) => Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))
    const mouse = this.mouseDown.flatMap(downEvent => {
      const p1 = [downEvent.clientX, downEvent.clientY]
      return this.mouseUp
        .map(upEvent => [upEvent.clientX, upEvent.clientY])
        .filter(p2 => dist(p1, p2) <= this.scale)
        .map(([x, y]) => this.getTilePosition(x, y))
    })

    const touch = this.touchStart.flatMap(startEvent => {
      const p1 = [startEvent.touches[0].clientX, startEvent.touches[0].clientY]
      return this.touchEnd
        .map(endEvent => [endEvent.changedTouches[0].clientX, endEvent.changedTouches[0].clientY])
        .filter(p2 => dist(p1, p2) <= this.scale)
        .map(([x, y]) => this.getTilePosition(x, y))
    })

    return Rx.Observable.merge(mouse, touch)
  }

  loadTiles(tiles) {
    const tileset = new PIXI.Texture.fromImage("/images/tiles.jpg")
    const result = {}
    for (const key in tiles) {
      const [tileX, tileY] = tiles[key]
      result[key] = new PIXI.Texture(tileset, new PIXI.Rectangle(tileX, tileY, this.textureSize, this.textureSize))
    }
    return result
  }
}
