defmodule Mana.User.LoginCommand do
  use Mana.Web, :command
  alias Mana.{User, Auth}

  def run(%{"username" => username, "password" => password}) do
    case Repo.get_by(User, username: username) do
      %User{} = user ->
        if Auth.check_password(password, user.encrypted_password) do
          {:ok, user}
        else
          {:error}
        end
      _ -> {:error}
    end
  end
end
