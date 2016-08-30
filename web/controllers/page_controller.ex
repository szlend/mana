defmodule Mana.PageController do
  use Mana.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def play(conn, _params) do
    token = :base64.encode(:crypto.strong_rand_bytes(32))
    conn
    |> assign(:token, token)
    |> put_layout("game.html")
    |> render("play.html")
  end
end
