defmodule Mana.Auth.Helpers do

  def current_user(conn) do
    user = Guardian.Plug.current_resource(conn)
    
    case user do
      %Mana.User{username: username} -> username
      _ -> "Anonymous"
    end
  end
end
