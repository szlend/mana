defmodule Mana.Game do
  use GenServer
  alias Mana.Board

  # Client

  def start_link() do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def join(user_id) do
    GenServer.call(__MODULE__, {:join, user_id})
  end

  def moves({x, y}, {w, h}) do
    GenServer.call(__MODULE__, {:moves, {x, y}, {w, h}})
  end

  def mines({x, y}, {w, h}) do
    GenServer.call(__MODULE__, {:mines, {x, y}, {w, h}})
  end

  def reveal(user_id, {x, y}) do
    GenServer.call(__MODULE__, {:reveal, user_id, {x, y}})
  end

  def get_users() do
    GenServer.call(__MODULE__, :users)
  end

  # Server

  def init(_) do
    {:ok, %{
      seed: :rand.uniform(),
      users: MapSet.new(),
      moves: Map.new(),
    }}
  end

  def handle_call(:users, _from, state) do
    {:reply, MapSet.to_list(state.users), state}
  end

  def handle_call({:join, user_id}, _from, state) do
    IO.puts "User #{user_id} joined game"
    state = %{state | users: MapSet.put(state.users, user_id)}
    {:reply, :ok, state}
  end

  def handle_call({:moves, {x, y}, {w, h}}, _from, state) do
    moves = Board.subset_moves(state.moves, {x, y}, {w, h})
    {:reply, {:ok, moves}, state}
  end

  def handle_call({:mines, {x, y}, {w, h}}, _from, state) do
    mines = Board.subset_mines(state.seed, {x, y}, {w, h})
    {:reply, {:ok, mines}, state}
  end

  def handle_call({:reveal, _user_id, {x, y}}, _from, state) do
    if state.moves[{x, y}] do
      {:reply, {:error, :move_exists}, state}
    else
      new_moves = Board.reveal(state.seed, state.moves, {x, y})
      moves = Map.merge(state.moves, new_moves)
      state = %{state | moves: moves}
      {:reply, {:ok, new_moves}, state}
    end
  end
end
