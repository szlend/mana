defmodule Mana.GridSupervisor do
  use Supervisor
  alias Mana.Grid

  # Client

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child({x, y}) do
    Supervisor.start_child(__MODULE__, [{x, y}])
  end

  def register({x, y}) do
    case Swarm.register_name(Grid.key({x, y}), __MODULE__, :start_child, [{x, y}]) do
      {:ok, pid} -> pid
      {:error, {:already_registered, pid}} -> pid
    end
  end

  def grid({x, y}) do
    {x, y} = Grid.position({x, y})
    case Swarm.whereis_name(Grid.key({x, y})) do
      :undefined -> register({x, y})
      pid -> pid
    end
  end

  # Server

  def init(_) do
    children = [
      worker(Mana.Grid, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
