defmodule Mana.ProfileController do
  use Mana.Web, :controller
  require IEx

  def edit(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)
    conn
    |> assign(:user, Repo.get(Mana.User, id))
    |> render("edit.html")
  end

  def update(conn, %{"id" => id, "user" => %{"username" => username}}) do
    {id, _} = Integer.parse(id)
    q = Repo.get(Mana.User, id)
    q = %{q | username: username }
    IEx.pry
    Repo.update(q)
    redirect conn, to: profile_path(conn, :edit, q.id)
  end
end