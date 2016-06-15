defmodule Mana.GamePlayerTest do
  use Mana.ModelCase

  alias Mana.GamePlayer

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GamePlayer.changeset(%GamePlayer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GamePlayer.changeset(%GamePlayer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
