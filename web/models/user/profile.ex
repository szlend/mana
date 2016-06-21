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

  def from_user(struct) do
    struct(Mana.User.Profile, Map.delete(struct, :__struct__))
  end
end
