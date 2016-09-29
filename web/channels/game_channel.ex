defmodule Mana.GameChannel do
  use Mana.Web, :channel
  alias Mana.{User, Grid, MoveTracker, Serializer}

  def join("game", %{"name" => name}, socket) do
    case User.register(name, self) do
      {:ok, user} ->
        last_move = MoveTracker.last_move
        socket = assign(socket, :user, user)
        {:ok, %{last_move: Serializer.position(last_move)}, socket}

      {:error, :invalid_name} ->
        {:error, %{code: "invalid_name", message: "Username is invalid."}}

      {:error, {:already_started, _}} ->
        {:error, %{code: "name_taken", message: "Username has been taken."}}
    end
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket)
  when is_integer(x) and is_integer(y) do
    Grid.reveal(User.name(socket.assigns.user), {x, y})
    {:noreply, socket}
  end

  def handle_info({:score, score}, socket) do
    push(socket, "score", %{score: score})
    {:noreply, socket}
  end
end
