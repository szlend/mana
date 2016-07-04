defmodule Mana.AuthErrorHandler do
  import Phoenix.Controller
  import Mana.Router.Helpers

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "You must be authenticated.")
    |> redirect(to: session_path(conn, :new))
  end

  def already_authenticated(conn, _params) do
    conn
    |> put_flash(:error, "Already authenticated.")
    |> redirect(to: "/")
  end
end
