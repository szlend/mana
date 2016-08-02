defmodule Mana.GameInstance do
  use GenServer

  # Client

  def start_link(name) do
    GenServer.start(__MODULE__, name, name: via_name(name))
  end

  def join(name, user_id) do
    GenServer.call(via_name(name), {:join, user_id})
  end

  def mines(name, {from_x, to_x}, {from_y, to_y}) do
    GenServer.call(via_name(name), {:mines, {from_x, to_x}, {from_y, to_y}})
  end

  def reveal(name, user_id, x, y) do
    GenServer.call(via_name(name), {:reveal, user_id, x, y})
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
      seed: :random.uniform(),
      users: MapSet.new(),
      moves: [],
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
    {:reply, :ok, add_user(state, user_id)}
  end

  def handle_call({:mines, {from_x, to_x}, {from_y, to_y}}, _from, state) do
    xs = from_x..to_x
    ys = from_y..to_y
    mines = for x <- xs, y <- ys, bomb?(state.seed, x, y), do: [x, y]
    {:reply, {:ok, mines}, state}
  end

  def handle_call({:reveal, user_id, x, y}, _from, %{moves: moves} = state) do
    move =
      if bomb?(state.seed, x, y) do
        {:bomb, user_id, x, y}
      else
        count = adjacent_bombs(state.seed, x, y)
        if count > 0 do
          {:adjacent_bombs, user_id, x, y, count}
        else
          {:empty, user_id, x, y}
        end
      end
    state = %{state | moves: [move | moves]}
    {:reply, {:ok, move}, state}
  end

  defp add_user(%{users: users} = state, user_id) do
    %{state | users: MapSet.put(users, user_id)}
  end

  defp bomb?(seed, x, y) do
    rem(:erlang.phash2({seed, x, y}), 1000) > 800
  end

  defp adjacent_bombs(seed, x, y) do
    bombs = [
      bomb?(seed, x + 0, y + 1),
      bomb?(seed, x + 1, y + 1),
      bomb?(seed, x + 1, y + 0),
      bomb?(seed, x + 1, y - 1),
      bomb?(seed, x + 0, y - 1),
      bomb?(seed, x - 1, y - 1),
      bomb?(seed, x - 1, y + 0),
      bomb?(seed, x - 1, y + 1)
    ]
    Enum.reduce(bombs, 0, fn(x, acc) -> acc + if(x, do: 1, else: 0) end)
  end
end
