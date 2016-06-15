defmodule Mana.User.Registration do
  use Mana.Web, :model
  import Mana.User

  schema "users" do
    field :username, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password, :password_confirmation])
    |> validate_required([:username, :password, :password_confirmation])
    |> validate_username
    |> validate_password
    |> hash_password
  end

  def to_user(struct) do
    struct(Mana.User, Map.delete(struct, :__struct__))
  end
end
