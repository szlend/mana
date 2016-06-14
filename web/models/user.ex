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
    |> validate_required(:username)
    |> validate_format(:username, ~r/[a-zA-Z0-9]{3,}/)
  end

  def validate_password(changeset) do
    changeset
    |> validate_required([:password, :password_confirmation])
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

defmodule Mana.User.Registration do
  import Ecto.Changeset
  import Mana.User

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password, :password_confirmation])
    |> validate_username
    |> validate_password
    |> hash_password
  end
end
