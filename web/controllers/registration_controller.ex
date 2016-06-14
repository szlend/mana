defmodule Mana.RegistrationController do
  use Mana.Web, :controller
  alias Mana.User

  def new(conn, _params) do
    changeset = User.Registration.changeset(%User{})
    render conn, "new.html", %{changeset: changeset}
  end

  def create(conn, %{"user" => user}) do
    changeset = User.Registration.changeset(%User{}, user)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Registered successfully.")
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Registration error.")
        |> render("new.html", %{changeset: changeset})
    end
  end
end
