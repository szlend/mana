defmodule Mana.Grid do
  use GenServer
  import Mana.GridSupervisor, only: [grid: 1]
  alias Mana.{Board, Serializer, Endpoint}

  @seed 1234
  @size 50

  # Client

  def start_link({x, y}) do
    GenServer.start_link(__MODULE__, {x, y}, name: via_grid({x, y}))
  end

  def size(), do: @size
  def seed(), do: @seed
  def find({x, y}), do: :syn.find_by_key(key({x, y}))
  def key({x, y}), do: {:grid, {x, y}}
  def via_grid({x, y}), do: {:via, :syn, key({x, y})}

  def reveal({x, y}) do
    GenServer.call(grid({x, y}), {:reveal, {x, y}})
  end

  def moves({x, y}) do
    GenServer.call(grid({x, y}), :moves)
  end

  def position({x, y}) do
    x = round(Float.floor(x / @size) * @size)
    y = round(Float.floor(y / @size) * @size)
    {x, y}
  end

  def valid_position?({x, y}) do
    match?({^x, ^y}, position({x, y}))
  end

  # Server

  def init({x, y}) do
    state = %{from: {x, y}, to: {x + @size - 1, y + @size - 1},
              seed: @seed, moves: %{}}
    IO.puts("Starting #{inspect({x, y})}")
    {:ok, state}
  end

  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, {:resume, state}, state}
  end

  def handle_call({:swarm, :end_handoff, state}, _from, _) do
    {:reply, :ok, state}
  end

  def handle_call({:reveal, {x, y}}, _from, state) do
    GenServer.cast(self, {:reveal, {x, y}})
    {:reply, :ok, state}
  end

  def handle_call(:moves, _from, state) do
    {:reply, state.moves, state}
  end

  def handle_cast({:reveal, tile}, state) do
    new_moves = reveal(state, tile)
    moves = Map.merge(state.moves, new_moves)
    broadcast_moves(state, new_moves)
    {:noreply, %{state | moves: moves}}
  end

  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end

  def reveal(state, tile) do
    if Board.mine?(state.seed, tile) do
      %{tile => Board.make_mine()}
    else
      reveal_empty(state, %{}, tile)
    end
  end

  def reveal_empty(state, moves, tile) do
    if Map.has_key?(state.moves, tile) or Map.has_key?(moves, tile) do
      moves
    else
      tiles = Board.adjacent_tiles(tile)
      count = Board.filter_mines(state.seed, tiles) |> Enum.count
      moves = Map.put(moves, tile, Board.make_empty(count))

      if count == 0 do
        {local, neigbour} = Enum.partition(tiles, &tile_inside_grid?(state, &1))
        Enum.each(neigbour, &GenServer.cast(grid(&1), {:reveal, &1}))
        Enum.reduce(local, moves,
          fn tile, moves -> reveal_empty(state, moves, tile) end)
      else
        moves
      end
    end
  end

  def tile_inside_grid?(state, {x, y}) do
    %{from: {x1, y1}, to: {x2, y2}} = state
    (x >= x1) and (y >= y1) and (x <= x2) and (y <= y2)
  end

  def topic(%{from: {x, y}}), do: "grid:#{x}:#{y}"

  def broadcast_moves(_state, moves) when moves == %{}, do: nil
  def broadcast_moves(state, moves) do
    moves = Serializer.moves(moves)
    Endpoint.broadcast!(topic(state), "reveal", %{moves: moves})
  end
end
