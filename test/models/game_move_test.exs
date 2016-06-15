defmodule Mana.GameMoveTest do
  use Mana.ModelCase

  alias Mana.GameMove

  @valid_attrs %{pos_x: 42, pos_y: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GameMove.changeset(%GameMove{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GameMove.changeset(%GameMove{}, @invalid_attrs)
    refute changeset.valid?
  end
end
