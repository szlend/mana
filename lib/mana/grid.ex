defmodule Mana.Grid do
  use GenServer
  import Mana.GridSupervisor, only: [grid: 1]
  alias Mana.{GridState, Board, MoveTracker, Serializer, Endpoint}

  @save_after_moves 10
  @sleep_after_ms 30_000

  # Client

  def start_link(seed, size, {x, y}) do
    GenServer.start_link(__MODULE__, {seed, size, {x, y}})
  end

  def key({x, y}), do: {:grid, {x, y}}
  def seed(), do: Application.fetch_env!(:mana, :grid_seed)
  def size(), do: Application.fetch_env!(:mana, :grid_size)
  def topic(%{from: {x, y}}), do: "grid:#{x}:#{y}"

  def reveal(user, {x, y}) do
    GenServer.call(grid({x, y}), {:reveal, user, {x, y}})
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
    Swarm.join(:grid, self)
    Process.flag(:trap_exit, true)
    :timer.send_interval(1_000, :sleep)

    state = %{
      from: {x, y},
      to: {x + size - 1, y + size - 1},
      seed: seed,
      size: size,
      moves: %{},
      moves_since_save: 0,
      last_move_at: now_ms}
    {:ok, GridState.load(state)}
  end

  def handle_call({:reveal, user, {x, y}}, _from, state) do
    GenServer.cast(self, {:reveal, user, {x, y}, :start})
    {:reply, :ok, state}
  end

  def handle_call(:moves, _from, state) do
    {:reply, state.moves, state}
  end

  def handle_cast({:reveal, user, tile, progress}, state) do
    new_moves = do_reveal(state, user, tile)
    moves = Map.merge(state.moves, new_moves)

    # broadcast moves to all players
    broadcast_moves(state, new_moves)

    # log last move if start of reveal
    if progress == :start && new_moves != %{} do
      type = moves[tile]
      MoveTracker.move(user, tile, type)
    end

    # persist moves into database if conditions met
    state = save_state_after_moves(state, @save_after_moves)

    {:noreply, %{state | moves: moves, last_move_at: now_ms}}
  end

  def handle_info(:sleep, state) do
    if now_ms - state.last_move_at > @sleep_after_ms do
      {:stop, :normal, state}
    else
      {:noreply, state}
    end
  end

  def terminate(_reason, state) do
    if state.moves_since_save > 0 do
      GridState.save(state)
    end
  end


  def do_reveal(state, user, tile) do
    if Board.mine?(state.seed, tile) do
      do_reveal_mine(state, tile)
    else
      do_reveal_empty(state, %{}, user, tile)
    end
  end

  def do_reveal_mine(state, tile) do
    if Map.has_key?(state.moves, tile) do
      %{}
    else
      %{tile => Board.make_mine()}
    end
  end

  def do_reveal_empty(state, moves, user, tile) do
    if Map.has_key?(state.moves, tile) or Map.has_key?(moves, tile) do
      moves
    else
      tiles = Board.adjacent_tiles(tile)
      count = Board.filter_mines(state.seed, tiles) |> Enum.count
      moves = Map.put(moves, tile, Board.make_empty(count))

      if count == 0 do
        {local, neigbour} = Enum.partition(tiles, &tile_inside_grid?(state, &1))
        Enum.each(neigbour, &GenServer.cast(grid(&1), {:reveal, user, &1, :continue}))
        Enum.reduce(local, moves,
          fn tile, moves -> do_reveal_empty(state, moves, user, tile) end)
      else
        moves
      end
    end
  end

  def tile_inside_grid?(state, {x, y}) do
    %{from: {x1, y1}, to: {x2, y2}} = state
    (x >= x1) and (y >= y1) and (x <= x2) and (y <= y2)
  end

  def save_state_after_moves(state, moves) do
    if state.moves_since_save == moves do
      GridState.save(state)
      %{state | moves_since_save: 0}
    else
      %{state | moves_since_save: state.moves_since_save + 1}
    end
  end

  def broadcast_moves(_state, moves) when moves == %{}, do: nil
  def broadcast_moves(state, moves) do
    moves = Serializer.moves(moves)
    Endpoint.broadcast!(topic(state), "reveal", %{moves: moves})
  end

  defp now_ms, do: :os.system_time(:millisecond)
end
