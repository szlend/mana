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
    name = socket.assigns.game
    {:ok, mines} = GameInstance.mines(name, {from_x, to_x}, {from_y, to_y})
    {:reply, {:ok, %{mines: mines}}, socket}
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket) do
    name = socket.assigns.game
    user_id = socket.assigns.id
    {:ok, move} = GameInstance.reveal(name, user_id, x, y)

    data = case move do
      {:bomb, user_id, x, y} ->
        %{move: %{type: :bomb, user_id: user_id, x: x, y: y}}
      {:adjacent_bombs, user_id, x, y, count} ->
        %{move: %{type: :adjacent_bombs, user_id: user_id, x: x, y: y, count: count}}
      {:empty, user_id, x, y} ->
        %{move: %{type: :empty, user_id: user_id, x: x, y: y}}
    end

    broadcast!(socket, "reveal", data)
    {:noreply, socket}
  end
end
