defmodule Mana.GamePlayer do
  use Mana.Web, :model

  schema "game_players" do
    belongs_to :user, Mana.User
    belongs_to :game, Mana.Game

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
