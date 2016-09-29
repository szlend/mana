defmodule Mana.Grid do
  use GenServer
  import Mana.GridSupervisor, only: [grid: 1]
  alias Mana.{GridState, Board, Serializer, Endpoint}

  @sleep_after 30_000
  @sleep_check_interval 1_000
  @save_interval 30_000
  @save_after_moves 10

  # Client

  def start_link(seed, size, {x, y}) do
    GenServer.start_link(__MODULE__, {seed, size, {x, y}})
  end

  def key({x, y}), do: {:grid, {x, y}}
  def seed(), do: Application.fetch_env!(:mana, :grid_seed)
  def size(), do: Application.fetch_env!(:mana, :grid_size)
  def topic(%{from: {x, y}}), do: "grid:#{x}:#{y}"

  def reveal({x, y}) do
    GenServer.call(grid({x, y}), {:reveal, {x, y}})
  end

  def moves({x, y}) do
    GenServer.call(grid({x, y}), :moves)
  end

  def position({x, y}) do
    x = round(Float.floor(x / size) * size)
    y = round(Float.floor(y / size) * size)
    {x, y}
  end

  def valid_position?({x, y}) do
    match?({^x, ^y}, position({x, y}))
  end

  # Server

  def init({seed, size, {x, y}}) do
    state = %{
      from: {x, y},
      to: {x + size - 1, y + size - 1},
      seed: seed,
      size: size,
      moves: %{},
      moves_since_save: 0,
      last_move_at: now_ms,
      last_saved_at: now_ms}
    :timer.send_interval(@sleep_check_interval, :sleep)
    :timer.send_interval(@save_interval, :save)
    Swarm.join(:grid, self)
    {:ok, GridState.load(state)}
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
    if state.moves_since_save == @save_after_moves, do: send(self, :save)
    {:noreply, %{state | moves: moves,
                         last_move_at: now_ms,
                         moves_since_save: state.moves_since_save + 1}}
  end

  def handle_info(:save, state) do
    {:noreply, save_state(state)}
  end

  def handle_info(:sleep, state) do
    if now_ms - state.last_move_at > @sleep_after do
      GridState.save(state)
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
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

  def save_state(state) do
    if state.moves_since_save > 0 do
      GridState.save(state)
      %{state | last_saved_at: now_ms, moves_since_save: 0}
    else
      state
    end
  end

  def broadcast_moves(_state, moves) when moves == %{}, do: nil
  def broadcast_moves(state, moves) do
    moves = Serializer.moves(moves)
    Endpoint.broadcast!(topic(state), "reveal", %{moves: moves})
  end

  defp now_ms, do: :os.system_time(:millisecond)
end
