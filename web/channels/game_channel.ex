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
        socket = assign(socket, :game, name)
        {:ok, %{users: current_users}, socket}
    end
  end

  def handle_in("mines", %{"x" => [from_x, to_x], "y" => [from_y, to_y]}, socket) do
    seed = "this is a seed for #{socket.assigns.game}"
    mines = for x <- (from_x .. to_x), y <- (from_y .. to_y), bomb?(seed, x, y), do: [x, y]
    {:reply, {:ok, %{mines: mines}}, socket}
  end

  # move this shit out of here please
  defp bomb?(seed, x, y) do
    rem(:erlang.phash2({seed, x, y}), 1000) > 800
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
