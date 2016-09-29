defmodule Mana.User do
  use GenServer

  # Client

  def register(name) do
    case valid_name?(name) do
      true -> GenServer.start_link(__MODULE__, name, name: via_name(name))
      false -> {:error, :invalid_name}
    end
  end

  def via_name(name), do: {:via, :swarm, {:user, String.downcase(name)}}
  def valid_name?(name), do: Regex.match?(~r/^[a-zA-Z0-9_]{2,8}$/, name)

  def find_by_name(name) do
    Swarm.whereis_name({:user, name})
  end

  def name(user) do
    GenServer.call(user, :name)
  end

  # Server

  def init(name) do
    :ok = Swarm.join(:user, self)
    {:ok, %{name: name}}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end
end
