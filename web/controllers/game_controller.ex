defmodule Mana.GameController do
  use Mana.Web, :controller
  import Mana.Router.Helpers
  alias Mana.GameInstance
  alias Mana.Game

  def index(conn, _params) do
    render conn, "index.html", games: Repo.all(Game)
  end

  def show(conn, %{"id" => name}) do
    case GenServer.whereis(GameInstance.via_name(name)) do
      nil ->
        conn
        |> put_flash(:error, "The specified game does not exist.")
        |> redirect(to: game_path(conn, :index))
      game ->
        name = GenServer.call(game, :name)
        render(conn, "show.html", %{name: name})
    end
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(_conn, _params) do
  end
end
