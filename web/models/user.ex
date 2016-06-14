defmodule Mana.User do
  use Mana.Web, :model

  schema "users" do
    field :username, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    timestamps
  end

  def validate_username(changeset) do
    changeset
    |> unique_constraint(:username)
    |> validate_format(:username, ~r/[a-zA-Z0-9]{3,}/)
  end

  def validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
  end

  def hash_password(changeset) do
    if password = get_change(changeset, :password) do
      encrypted_password = Comeonin.Bcrypt.hashpwsalt(password)
      put_change(changeset, :encrypted_password, encrypted_password)
    else
      changeset
    end
  end
end
