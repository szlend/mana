defmodule Mana.GameChannel do
  use Mana.Web, :channel
  alias Mana.GameInstance

  def join("game:" <> name, _payload, socket) do
    case GenServer.whereis(GameInstance.via_name(name)) do
      nil ->
        {:error, %{reason: "not_found"}}
      _ ->
        :ok = GameInstance.join(name, socket.assigns.id)
        users_ids = GameInstance.get_users(name)
        current_users = Repo.all(from u in Mana.User, select: u.username, where: u.id in ^users_ids)
        {:ok, current_users, socket}
    end
  end

  # def handle_in("create", %{"name" => name}, socket) do
  #   case Mana.GameSupervisor.create_game(name) do
  #     {:ok, game} ->
  #       name = GenServer.call(game, :name)
  #       {:reply, {:ok, %{name: name}}, socket}
  #     {:error, _} ->
  #       {:reply, {:error, %{message: "Oh no, it already exists? maby?"}}, socket}
  #   end
  # end
  #
  # def handle_in("join", %{"name" => name}, socket) do
  #
  # end
end
