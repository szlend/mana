defmodule Mana.GameChannel do
  use Mana.Web, :channel

  def join("game:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("create", %{"name" => name}, socket) do
    case Mana.GameSupervisor.create_game(name) do
      {:ok, game} ->
        name = GenServer.call(game, :name)
        {:reply, {:ok, %{name: name}}, socket}
      {:error, _} ->
        {:reply, {:error, %{message: "Oh no, it already exists? maby?"}}, socket}
    end
  end

  # def handle_in("join", %{"name" => name}, socket) do
  #
  # end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
