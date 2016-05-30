defmodule Mana.User do
  use Mana.Web, :model

  schema "users" do
    field :username, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    timestamps
  end

  @required_fields ~w(username)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_user
  end

  def validate_user(changeset) do
    changeset
    |> unique_constraint(:username)
    |> validate_format(:username, ~r/[a-zA-Z0-9]{3,}/)
  end
end

defmodule Mana.User.Registration do
  import Ecto.Changeset
  import Mana.User, only: [validate_user: 1]

  @required_fields ~w(username password)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_change(:encrypted_password, hash_password(params[:password]))
    |> validate_user
  end

  defp hash_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end
end
