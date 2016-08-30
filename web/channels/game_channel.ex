defmodule Mana.GameChannel do
  use Mana.Web, :channel
  alias Mana.{Game, MoveTracker}

  def join("game", _payload, socket) do
    :ok = Game.join(socket.assigns.token)
    users_ids = Game.get_users()
    {:ok, last_move} = MoveTracker.last_move()
    {:ok, %{users: users_ids, last_move: serialize_last_move(last_move)}, socket}
  end

  def handle_in("moves", %{"x" => x, "y" => y, "w" => w, "h" => h}, socket)
  when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    {:ok, moves} = Game.moves({x, y}, {w, h})
    {:reply, {:ok, %{moves: serialize_moves(moves)}}, socket}
  end

  def handle_in("mines", %{"x" => x, "y" => y, "w" => w, "h" => h}, socket)
  when is_integer(x) and is_integer(y) and is_integer(w) and is_integer(h) do
    {:ok, mines} = Game.mines({x, y}, {w, h})
    {:reply, {:ok, %{mines: serialize_mines(mines)}}, socket}
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket)
  when is_integer(x) and is_integer(y) do
    user_id = socket.assigns.token
    case Game.reveal(user_id, {x, y}) do
      {:error, :move_exists} -> nil
      {:ok, moves} ->
        {:ok, score} = MoveTracker.move(user_id, {x, y}, moves)
        broadcast!(socket, "reveal", %{moves: serialize_moves(moves), user_id: user_id, score: score})
    end
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
