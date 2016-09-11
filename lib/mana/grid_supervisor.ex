defmodule Mana.GridSupervisor do
  use Supervisor
  use Retry
  alias Mana.{Ring, Grid}

  # Client

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def find_or_start_child({x, y}) do
    case Supervisor.start_child(__MODULE__, [{x, y}]) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def find_or_start_distributed_child({x, y}) do
    retry with: exp_backoff |> expiry(10_000) do
      node = Ring.find(Grid.key({x, y}))
      case :rpc.call(node, __MODULE__, :find_or_start_child, [{x, y}]) do
        {:ok, pid} -> {:ok, pid}
        error -> {:error, error}
      end
    end
  end

  def grid({x, y}) do
    {x, y} = Grid.position({x, y})
    case Grid.find({x, y}) do
      :undefined -> find_or_start_distributed_child({x, y}) |> unwrap
      pid -> pid
    end
  end

  defp unwrap({:ok, result}), do: result

  # Server

  def init(_) do
    children = [
      worker(Mana.Grid, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
