defmodule Mana.GameChannel do
  use Mana.Web, :channel
  alias Mana.{GameInstance, MoveTracker}

  def join("game:" <> name, _payload, socket) do
    case GenServer.whereis(GameInstance.via_name(name)) do
      nil ->
        {:error, %{reason: "not_found"}}
      _ ->
        :ok = GameInstance.join(name, socket.assigns.id)
        users_ids = GameInstance.get_users(name)
        current_users = Repo.all(from u in Mana.User, select: u.username, where: u.id in ^users_ids)
        {:ok, last_move} = MoveTracker.last_move()
        socket = assign(socket, :game, name)
        {:ok, %{users: current_users, last_move: serialize_last_move(last_move)}, socket}
    end
  end

  def handle_in("moves", %{"x" => x, "y" => y, "w" => w, "h" => h}, socket)
  when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    name = socket.assigns.game
    {:ok, moves} = GameInstance.moves(name, {x, y}, {w, h})
    {:reply, {:ok, %{moves: serialize_moves(moves)}}, socket}
  end

  def handle_in("mines", %{"x" => x, "y" => y, "w" => w, "h" => h}, socket)
  when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    name = socket.assigns.game
    {:ok, mines} = GameInstance.mines(name, {x, y}, {w, h})
    {:reply, {:ok, %{mines: serialize_mines(mines)}}, socket}
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket)
  when is_integer(x) and is_integer(y) do
    name = socket.assigns.game
    user_id = socket.assigns.id
    {:ok, moves} = GameInstance.reveal(name, user_id, {x, y})
    {:ok, score} = MoveTracker.move(user_id, {x, y}, moves)
    broadcast!(socket, "reveal", %{moves: serialize_moves(moves), user_id: user_id, score: score})
    {:noreply, socket}
  end

  defp serialize_moves(moves) do
    Enum.map(moves, fn {{x, y}, move} -> [x, y, serialize_move(move)] end)
  end

  defp serialize_mines(mines) do
    Enum.map(mines, fn {x, y} -> [x, y] end)
  end

  defp serialize_last_move(last_move) do
    case last_move do
      {user_id, {x, y}} -> %{user_id: user_id, x: x, y: y}
      nil -> nil
    end
  end

  defp serialize_move(:mine), do: 9
  defp serialize_move({:empty, count}), do: count
end
