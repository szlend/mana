defmodule Mana.GameController do
  use Mana.Web, :controller
  import Mana.Router.Helpers
  alias Mana.GameInstance
  alias Mana.Game

#  def index(conn, _params) do
#    render conn, "index.html", games: Repo.all(Game)
#  end

  def index(conn, _params) do
    games =
      GameInstance.list()
      |> Enum.map(fn {_, name} -> name end)

    render conn, "index.html", games: games
  end

  def show(conn, %{"id" => name}) do
    case GenServer.whereis(GameInstance.via_name(name)) do
      nil ->
        conn
        |> put_flash(:error, "The specified game does not exist.")
        |> redirect(to: game_path(conn, :index))
      game ->
        render(conn, "show.html", name: name)
    end
  end

  def new(conn, _params) do

    render conn, "new.html"
  end

  def create(conn, %{"game" => %{"name" => name}}) do
    case Game.CreateCommand.run(name) do
      :ok -> redirect(conn, to: game_path(conn, :show, name))
      :error ->
        conn
        |> put_flash(:error, "Game with this name already exists.")
        |> render("new.html")
    end
  end
end
