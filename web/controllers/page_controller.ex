defmodule Mana.PageController do
  use Mana.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def error(conn, %{"message" => message}) do
    conn
    |> put_flash(:error, "Error: #{message}")
    |> redirect(to: page_path(conn, :index))
  end
end
