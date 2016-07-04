defmodule Mana.PageController do
  use Mana.Web, :controller
  import Mana.Router.Helpers

  def index(conn, _params) do
    render conn, "index.html"
  end
end
