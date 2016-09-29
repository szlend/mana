defmodule Mana.Serializer do
  def moves(moves) do
    Enum.map(moves, fn {{x, y}, move} -> [x, y, move(move)] end)
  end

  def mines(mines) do
    Enum.map(mines, fn {x, y} -> [x, y] end)
  end

  def scores(scores) do
    Enum.into(scores, %{})
  end

  def position(nil), do: nil
  def position({x, y}), do: %{x: x, y: y}

  def user_move({user_id, {x, y}}), do: %{user_id: user_id, x: x, y: y}
  def user_move(nil), do: nil

  def move(:mine), do: 9
  def move(:flag), do: 10
  def move({:empty, count}), do: count
end
