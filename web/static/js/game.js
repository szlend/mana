import PIXI from "pixi.js"
import Rx from "rx-lite-dom-events"
import {mod} from "./util"

export default class Engine {
  constructor(canvas, gridSize, options = {}) {
    this.renderer = PIXI.autoDetectRenderer(0, 0, {view: canvas, backgroundColor: 0xFFFFFF})
    this.scene = new PIXI.Container()
    this.map = new PIXI.Container()
    this.grid = []

    this.scene.addChild(this.map)

    this.scale = options.scale || 1
    this.width = 0
    this.height = 0
    this.gridSize = gridSize
    this.tileSize = 32 * this.scale

    // Tileset texture info
    this.textureSize = 128
    this.textureScale = this.tileSize / this.textureSize

    // Camera pixel position on the map (top-left)
    this.cameraX = 0
    this.cameraY = 0

    // List of all moves
    this.moves = {}

    // List of subscribed grids
    this.grids = []

    // Game running state
    this.running = false

    // Should the game re-render
    this.update = true

    // Event observers
    this.mouseDown = Rx.Observable.fromEvent(this.renderer.view, "mousedown")
    this.mouseUp = Rx.Observable.fromEvent(this.renderer.view, "mouseup")
    this.mouseMove = Rx.Observable.fromEvent(this.renderer.view, "mousemove")
    this.mouseOut = Rx.Observable.fromEvent(this.renderer.view, "mouseout")
    this.touchStart = Rx.Observable.fromEvent(this.renderer.view, "touchstart")
    this.touchEnd = Rx.Observable.fromEvent(this.renderer.view, "touchend")
    this.touchMove = Rx.Observable.fromEvent(this.renderer.view, "touchmove")
    this.mouseScroll = Rx.Observable.fromEvent(this.renderer.view, "mousewheel")
    this.cameraMove = this.cameraMoveObserver()
    this.tileClick = this.tileClickObserver()

    // Callbacks
    this.onCameraMove = () => {}
    this.onTileClick = () => {}
    this.onRequestGrid = () => {}
    this.onDisposeGrid = () => {}
  }

  run() {
    if (this.running) throw "Game is already running."
    this.running = true

    // Set tiles
    this.tiles = this.loadTiles({
      [-1]: [  0,   0],  // unclear
      [10]: [128,   0],  // flag
      [9]:  [256,   0],  // mine
      [0]:  [384,   0],  // empty
      [1]:  [  0, 128],  // 1
      [2]:  [128, 128],  // 2
      [3]:  [256, 128],  // 3
      [4]:  [384, 128],  // 4
      [5]:  [  0, 256],  // 5
      [6]:  [128, 256],  // 6
      [7]:  [256, 256],  // 7
      [8]:  [384, 256]   // 8
    })

    // Subscribe to tile clicks
    this.tileClick.subscribe(([x, y]) => this.onTileClick(x, y))

    // Subscribe to camera movement
    this.cameraMove.subscribe(([x, y]) => this.updateCamera(x, y))

    // Request starting grid
    this.resizeContainer()
    this.setCameraTileCoordinates(0, 0)

    // Start rendering
    this.render()

    // Fix issue with render after slow resize
    setTimeout(() => this.update = true, 100)
  }

  render() {
    const render = this.render.bind(this)
    this.resizeContainer()
    if (this.update) {
      this.updateGrid()
      this.map.position.x = -mod(this.cameraX, this.tileSize)
      this.map.position.y = -mod(this.cameraY, this.tileSize)
      this.renderer.render(this.scene)
      this.update = false
    }
    requestAnimationFrame(render)
  }

  resizeContainer() {
    const view = this.renderer.view
    const width = view.clientWidth
    const height = view.clientHeight

    this.width = width * this.scale
    this.height = height * this.scale

    if (view.width !== this.width || view.height !== this.height) {
      this.renderer.resize(this.width, this.height)
      this.requestSize = 3 * Math.ceil(Math.max(this.width, this.height) / this.tileSize)
      this.resizeGrid()
      this.update = true
    }
  }

  resizeGrid() {
    const tileSize = this.tileSize
    const [width, height] = this.getTileDimensions()
    const length = width * height

    // skip if grid already correct size
    if (this.grid.length === length) {
      return
    }

    // add sprites to grid
    while (this.grid.length < length) {
      const sprite = new PIXI.Sprite()
      sprite.scale.set(this.textureScale)
      this.grid.push(sprite)
      this.map.addChild(sprite)
    }

    // remove sprites from grid
    while (this.grid.length > length) {
      const sprite = this.grid.pop()
      this.map.removeChild(sprite)
    }

    if (this.grid.length > length) {
      this.grid.splice(0, length)
    }

    // update sprite positions
    let i = 0
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const sprite = this.grid[i]
        sprite.position.x = x * tileSize
        sprite.position.y = y * tileSize
        i++
      }
    }
  }

  updateGrid() {
    const tileSize = this.tileSize
    const [width, height] = this.getTileDimensions()
    const offsetX = Math.floor(this.cameraX / tileSize)
    const offsetY = Math.floor(this.cameraY / tileSize)
    const endX = offsetX + width
    const endY = offsetY + height

    let i = 0
    for (let y = offsetY; y < endY; y++) {
      for (let x = offsetX; x < endX; x++) {
        const sprite = this.grid[i]
        const move = this.moves[y] && this.moves[y][x]
        sprite.texture = move === undefined ? this.tiles[-1] : this.tiles[move]
        i++
      }
    }
  }

  updateCamera(x, y) {
    this.cameraX = x
    this.cameraY = y
    this.update = true

    this.requestGrid()
    this.onCameraMove(x, y)
  }

  getGridsInView() {
    const size = this.gridSize
    const [midX, midY] = this.getCameraTileCoordinates()
    const [midGridX, midGridY] = [midX - size / 2, midY - size / 2]
    const x1 = Math.floor(midGridX / size) * size
    const y1 = Math.floor(midGridY / size) * size
    const x2 = Math.ceil(midGridX / size) * size
    const y2 = Math.ceil(midGridY / size) * size

    return [[x1, y1], [x1, y2], [x2, y1], [x2, y2]]
  }

  gridsDiff(g1, g2) {
    const added = []
    const removed = []

    for (let [x1, y1] of g1) {
      let found = false
      for (let [x2, y2] of g2) {
        if (x1 === x2 && y1 === y2) {
          found = true
          break
        }
      }

      if (!found) {
        added.push([x1, y1])
      }
    }

    for (let [x2, y2] of g2) {
      let found = false
      for (let [x1, y1] of g1) {
        if (x1 === x2 && y1 === y2) {
          found = true
          break
        }
      }

      if (!found) {
        removed.push([x2, y2])
      }
    }

    return [added, removed]
  }

  requestGrid() {
    const grids = this.getGridsInView()
    const [added, removed] = this.gridsDiff(grids, this.grids)

    for (const [x, y] of added) {
      this.onRequestGrid(x, y)
    }

    for (const [x, y] of removed) {
      this.onDisposeGrid(x, y)
    }

    this.grids = grids
  }

  cleanupGrid(fromX, fromY) {
    const toX = fromX + this.gridSize
    const toY = fromY + this.gridSize
    for (const y in this.moves) {
      for (const x in this.moves[y]) {
        if (x >= fromX && x < toX && y >= fromY && y < toY) {
          delete this.moves[y][x]
        }
      }
    }
    this.update = true
  }

  addMoves(moves) {
    for (const [x, y, move] of moves) {
      this.moves[y] = this.moves[y] || {}
      this.moves[y][x] = move
    }
    this.update = true
  }

  addMines(mines) {
    for (const [x, y] of mines) {
      this.moves[y] = this.moves[y] || {}
      this.moves[y][x] = 10
    }
    this.update = true
  }

  getTileDimensions() {
    const width = Math.ceil(this.width / this.tileSize) + 1
    const height = Math.ceil(this.height / this.tileSize) + 1
    return [width, height]
  }

  getScreenTileCoordinates(pixelX, pixelY) {
    const x = Math.floor((this.cameraX + (pixelX * this.scale)) / this.tileSize)
    const y = Math.floor((this.cameraY + (pixelY * this.scale)) / this.tileSize)
    return [x, y]
  }

  getCameraTileCoordinates() {
    const x = Math.round((this.cameraX + this.width / 2) / this.tileSize)
    const y = Math.round((this.cameraY + this.height / 2) / this.tileSize)
    return [x, y]
  }

  setCameraTileCoordinates(x, y) {
    const midX = Math.round(this.width / 2)
    const midY = Math.round(this.height / 2)
    this.updateCamera(midX + x * this.tileSize, midY + y * this.tileSize)
  }

  cameraMoveObserver() {
    const mouse = this.mouseDown.flatMap(downEvent => {
      const [cameraX, cameraY] = [this.cameraX, this.cameraY]
      return this.mouseMove
        .takeUntil(this.mouseUp)
        .takeUntil(this.mouseOut)
        .map(moveEvent => [
          cameraX + (downEvent.clientX - moveEvent.clientX) * this.scale,
          cameraY + (downEvent.clientY - moveEvent.clientY) * this.scale
        ])
    })

    const touch = this.touchStart.flatMap(startEvent => {
      const [cameraX, cameraY] = [this.cameraX, this.cameraY]
      return this.touchMove
        .takeUntil(this.touchEnd)
        .map(moveEvent => [
          cameraX + (startEvent.touches[0].clientX - moveEvent.touches[0].clientX) * this.scale,
          cameraY + (startEvent.touches[0].clientY - moveEvent.touches[0].clientY) * this.scale
        ])
    })

    const scroll = this.mouseScroll.map(event => {
      const hasDelta = event.deltaX !== undefined
      return [
        this.cameraX + (hasDelta ? event.deltaX : (event.wheelDeltaX || 0)),
        this.cameraY + (hasDelta ? event.deltaY : (event.wheelDeltaY || event.wheelDelta || 0))
      ]
    })

    return Rx.Observable.merge(mouse, touch, scroll)
  }

  tileClickObserver() {
    const dist = ([x1, y1], [x2, y2]) => Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))
    const mouse = this.mouseDown.flatMap(downEvent => {
      const p1 = [downEvent.clientX, downEvent.clientY]
      return this.mouseUp
        .map(upEvent => [upEvent.clientX, upEvent.clientY])
        .filter(p2 => dist(p1, p2) <= this.scale)
        .map(([x, y]) => this.getScreenTileCoordinates(x, y))
    })

    const touch = this.touchStart.flatMap(startEvent => {
      const p1 = [startEvent.touches[0].clientX, startEvent.touches[0].clientY]
      return this.touchEnd
        .map(endEvent => [endEvent.changedTouches[0].clientX, endEvent.changedTouches[0].clientY])
        .filter(p2 => dist(p1, p2) <= this.scale)
        .map(([x, y]) => this.getScreenTileCoordinates(x, y))
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
