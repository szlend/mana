defmodule Mana.ProfileController do
  use Mana.Web, :controller
  alias Mana.User.Profile

  plug :scrub_params, "profile" when action in [:update]

  def edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    profile = Profile.from_user(user)
    changeset = Profile.changeset(profile)
    conn
    |> render("edit.html", %{profile: profile, changeset: changeset})
  end

  def update(conn, %{"profile" => profile_params}) do
    user = Guardian.Plug.current_resource(conn)
    profile = Profile.from_user(user)
    changeset = Profile.changeset(profile, profile_params)
    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Updated profile successfully.")
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Error updating profile.")
        |> render("edit.html", %{profile: profile, changeset: changeset})
    end
  end
end
