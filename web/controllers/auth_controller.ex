defmodule Mana.AuthController do
  use Mana.Web, :controller

  def login(conn, %{"login" => login}) do
    case Mana.User.LoginCommand.run(login) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Successfully signed in.")
        |> redirect(to: "/")
      {:error} ->
        conn
        |> put_flash(:error, "Wrong credentials.")
        |> login(%{})
    end
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
