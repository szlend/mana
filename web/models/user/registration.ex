defmodule Mana.User.Registration do
  import Ecto.Changeset
  import Mana.User

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password, :password_confirmation])
    |> validate_required([:username, :password, :password_confirmation])
    |> validate_username
    |> validate_password
    |> hash_password
  end
end
