defmodule Mana.User.Profile do
  use Mana.Web, :model
  import Mana.User

  schema "users" do
    field :username, :string
    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username])
    |> validate_required([:username])
    |> validate_username
  end

  def to_user(struct) do
    struct(Mana.User, Map.delete(struct, :__struct__))
  end
end
