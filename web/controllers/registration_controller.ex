defmodule Mana.RegistrationController do
  use Mana.Web, :controller
  alias Mana.User.RegistrationCommand

  plug :scrub_params, "registration" when action in [:create]

  def new(conn, _params) do
    changeset = RegistrationCommand.prepare()
    render(conn, "new.html", %{changeset: changeset})
  end

  def create(conn, %{"registration" => registration_params}) do
    case RegistrationCommand.run(registration_params) do
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
