defmodule Mana.Game do
  use Mana.Web, :model

  schema "games" do
    field :name, :string
    field :status, :string
    belongs_to :user, Mana.User
    
    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :status])
    |> validate_required([:name, :status])
  end
end
