defmodule Mana.Auth do
  def hash_password(password) when is_binary(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end

  def check_password(plain, hashed) when is_binary(plain) and is_binary(hashed) do
    Comeonin.Bcrypt.checkpw(plain, hashed)
  end
end
