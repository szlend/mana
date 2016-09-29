defmodule Mana.User do
  use GenServer

  # Client

  def register(name, channel) do
    case valid_name?(name) do
      true -> GenServer.start_link(__MODULE__, {channel, name}, name: via_name(name))
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

  def send_score(user, score) do
    GenServer.cast(user, {:send_score, score})
  end

  # Server

  def init({channel, name}) do
    :ok = Swarm.join(:user, self)
    {:ok, %{channel: channel, name: name}}
  end

  def handle_call(:name, _from, state) do
    {:reply, state.name, state}
  end

  def handle_cast({:send_score, score}, state) do
    send(state.channel, {:score, score})
    {:noreply, state}
  end
end
