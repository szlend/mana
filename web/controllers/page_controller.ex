defmodule Mana.PageController do
  use Mana.Web, :controller
  alias Mana.{User, Grid}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, %{"params" => %{"name" => name}}) do
    redirect(conn, to: page_path(conn, :play, name))
  end

  def play(conn, %{"name" => name}) do
    token = :base64.encode(:crypto.strong_rand_bytes(32))
    size = Grid.size()

    case can_join?(name) do
      :ok ->
        conn
        |> put_layout("game.html")
        |> render("play.html", token: token, name: name, size: size)

      {:error, message} ->
        conn
        |> put_flash(:error, "Error: #{message}")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def error(conn, %{"message" => message}) do
    conn
    |> put_flash(:error, "Error: #{message}")
    |> redirect(to: page_path(conn, :index))
  end

  defp can_join?(name) do
    cond do
      String.length(name) > 8 ->
        {:error, "Username is too long."}

      String.length(name) < 2 ->
        {:error, "Username is too short."}

      User.valid_name?(name) == false ->
        {:error, "Username contains invalid characters."}

      is_pid(User.find_by_name(name)) ->
        {:error, "Username has been taken."}

      true ->
        :ok
    end
  end
end
