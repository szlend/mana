defmodule Mana.User.LoginCommand do
  use Mana.Web, :command
  
  def run(%{"username" => username, "password" => password}) do
    case Repo.get_by(Mana.User, username: username) do
      %Mana.User{encrypted_password: enc_pass} = user ->
	case Mana.Auth.check_password(password, enc_pass) do
	  true -> {:ok, user}
	  false -> {:error}
	end
	
      _ -> {:error}
    end
  end
end
