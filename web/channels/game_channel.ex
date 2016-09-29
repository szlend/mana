defmodule Mana.GameChannel do
  use Mana.Web, :channel
  alias Mana.{User, Grid}

  def join("game", %{"name" => name}, socket) do
    case User.register(name) do
      {:ok, user} ->
        socket = assign(socket, :user, user)
        {:ok, %{last_move: nil}, socket}

      {:error, :invalid_name} ->
        {:error, %{code: "invalid_name", message: "Username is invalid."}}

      {:error, {:already_started, _}} ->
        {:error, %{code: "name_taken", message: "Username has been taken."}}
    end
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket)
  when is_integer(x) and is_integer(y) do
    Grid.reveal({x, y})
    {:noreply, socket}
  end
end
