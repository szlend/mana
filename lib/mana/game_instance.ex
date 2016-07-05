defmodule Mana.GameInstance do
  use GenServer

  # Client

  def start_link(name) do
    GenServer.start(__MODULE__, name, name: via_name(name))
  end

  def join(name, user_id) do
    GenServer.call(via_name(name), {:join, user_id})
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
    {:ok, %{name: name}}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_call({:join, user_id}, _from, state) do
    IO.puts "User #{user_id} joined game #{state.name}."
    {:reply, :ok, state}
  end
end
