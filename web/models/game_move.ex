defmodule Mana.GameMove do
  use Mana.Web, :model

  schema "game_moves" do
    field :pos_x, :integer
    field :pos_y, :integer
    belongs_to :game, Mana.Game
    belongs_to :user, Mana.User

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pos_x, :pos_y])
    |> validate_required([:pos_x, :pos_y])
  end
end
