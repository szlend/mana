defmodule Mana.PageController do
  use Mana.Web, :controller
  alias Mana.Grid

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def play(conn, _params) do
    token = :base64.encode(:crypto.strong_rand_bytes(32))
    size = Grid.size()
    conn
    |> put_layout("game.html")
    |> render("play.html", token: token, size: size)
  end
end
