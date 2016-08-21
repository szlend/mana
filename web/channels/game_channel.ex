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

  def handle_in("moves", %{"x" => x, "y" => y, "w" => w, "h" => h}, socket)
  when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    name = socket.assigns.game
    {:ok, moves} = GameInstance.moves(name, {x, y}, {w, h})
    {:reply, {:ok, %{moves: moves}}, socket}
  end

  def handle_in("mines", %{"x" => x, "y" => y, "w" => w, "h" => h}, socket)
  when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    name = socket.assigns.game
    {:ok, mines} = GameInstance.mines(name, {x, y}, {w, h})
    {:reply, {:ok, %{mines: mines}}, socket}
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket)
  when is_integer(x) and is_integer(y) do
    name = socket.assigns.game
    user_id = socket.assigns.id
    {:ok, moves} = GameInstance.reveal(name, user_id, {x, y})
    broadcast!(socket, "reveal", %{moves: moves})
    {:noreply, socket}
  end
end
