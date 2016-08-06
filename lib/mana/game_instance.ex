defmodule Mana.GameInstance do
  use GenServer
  alias Mana.Board

  # Client

  def start_link(name) do
    GenServer.start(__MODULE__, name, name: via_name(name))
  end

  def join(name, user_id) do
    GenServer.call(via_name(name), {:join, user_id})
  end

  def moves(name, {x, y}, {w, h}) do
    GenServer.call(via_name(name), {:moves, {x, y}, {w, h}})
  end

  def mines(name, {x, y}, {w, h}) do
    GenServer.call(via_name(name), {:mines, {x, y}, {w, h}})
  end

  def reveal(name, user_id, {x, y}) do
    GenServer.call(via_name(name), {:reveal, user_id, {x, y}})
  end

  def get_users(name) do
    GenServer.call(via_name(name), :users)
  end

  def via_name(name) do
    {:via, :gproc, {:n, :l, {:game, name}}}
  end

  def list() do
    :gproc.lookup_values({:p, :l, :game})
  end

  # Server

  def init(name) do
    :gproc.reg({:p, :l, :game}, name)
    {:ok, %{
      name: name,
      seed: :rand.uniform(),
      users: MapSet.new(),
      moves: Map.new(),
    }}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_call(:users, _from, state) do
    {:reply, MapSet.to_list(state.users), state}
  end

  def handle_call({:join, user_id}, _from, state) do
    IO.puts "User #{user_id} joined game #{state.name}."
    state = %{state | users: MapSet.put(state.users, user_id)}
    {:reply, :ok, state}
  end

  def handle_call({:moves, {x, y}, {w, h}}, _from, state) do
    moves = Board.serialize_moves(state.moves, {x, y}, {w, h})
    {:reply, {:ok, moves}, state}
  end

  def handle_call({:mines, {x, y}, {w, h}}, _from, state) do
    mines = Board.serialize_mines(state.seed, {x, y}, {w, h})
    {:reply, {:ok, mines}, state}
  end

  def handle_call({:reveal, _user_id, {x, y}}, _from, state) do
    new_moves = Board.reveal(state.seed, state.moves, {x, y})
    resp = Board.serialize_moves(new_moves)
    moves = Map.merge(state.moves, new_moves)
    state = %{state | moves: moves}
    {:reply, {:ok, resp}, state}
  end
end
