defmodule Mana.SessionController do
  use Mana.Web, :controller
  alias Mana.User.LoginCommand

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"login" => login}) do
    case LoginCommand.run(login) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Successfully signed in.")
        |> redirect(to: "/")
      {:error} ->
        conn
        |> put_flash(:error, "Wrong credentials.")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
