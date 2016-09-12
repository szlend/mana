defmodule Mana.Ring do
  use GenServer

  # Client

  def start_link(), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def find(name) do
    {:ok, node} = :hash_ring.find_node(:mana_ring, inspect(name))
    :"#{node}"
  end

  def all(), do: GenServer.call(__MODULE__, :nodes)

  # Server

  def init(_) do
    :ok = :net_kernel.monitor_nodes(true, [node_type: :all])
    :ok = :hash_ring.create_ring(:mana_ring, 128)
    :ok = :hash_ring.add_node(:mana_ring, "#{Node.self}")
    {:ok, []}
  end

  def handle_call(:nodes, _from, nodes), do: {:reply, nodes, nodes}
  def handle_call(_, _from, nodes), do: {:noreply, nodes}

  def handle_info({:nodeup, node, _info}, nodes) do
    handle_info({:nodeup, node}, nodes)
  end

  def handle_info({:nodeup, node}, nodes) do
    :ok = :hash_ring.add_node(:mana_ring, "#{node}")
    {:noreply, [node | nodes]}
  end

  def handle_info({:nodedown, node, _info}, nodes) do
    handle_info({:nodedown, node}, nodes)
  end

  def handle_info({:nodedown, node}, nodes) do
    :ok = :hash_ring.remove_node(:mana_ring, "#{node}")
    {:noreply, nodes -- [node]}
  end

  def handle_info(_, nodes) do
    {:noreply, nodes}
  end

  def terminate(_reason, _state) do
    :ok = :hash_ring.delete_ring(:mana_ring)
  end
end
