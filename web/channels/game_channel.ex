defmodule Mana.GameChannel do
  use Mana.Web, :channel
  alias Mana.Grid

  def join("game", _payload, socket) do
    {:ok, %{last_move: nil, users: []}, socket}
  end

  def handle_in("reveal", %{"x" => x, "y" => y}, socket)
  when is_integer(x) and is_integer(y) do
    Grid.reveal({x, y})
    {:noreply, socket}
  end
end
