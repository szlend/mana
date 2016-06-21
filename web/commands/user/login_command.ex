defmodule Mana.User.LoginCommand do
  use Mana.Web, :command

  def run(%{"username" => username, "password" => password}) do
    case Repo.get_by(Mana.User, username: username) do
      %Mana.User{} = user ->
        if Mana.Auth.check_password(password, user.encrypted_password) do
          {:ok, user}
        else
          {:error}
        end
      _ -> {:error}
    end
  end
end
