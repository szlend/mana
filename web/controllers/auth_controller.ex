defmodule Mana.AuthController do
  use Mana.Web, :controller

  def login(conn, %{"login" => login}) do
    case Mana.User.LoginCommand.run(login) do
      {:ok, user} ->
	conn
	|> Guardian.Plug.sign_in(user)
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
end
