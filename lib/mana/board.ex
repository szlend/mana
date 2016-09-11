defmodule Mana.Board do
  def mine?(seed, {x, y}) do
    rem(:erlang.phash2({seed, x, y}), 1000) > 800
  end

  def mines(seed, {x, y}, size) do
    {xs, ys} = {x..x+size-1, y..y+size-1}
    for x <- xs, y <- ys, mine?(seed, {x, y}), do: {x, y}
  end

  def adjacent_tiles({x, y}) do
    [{x + 0, y + 1},
     {x + 1, y + 1},
     {x + 1, y + 0},
     {x + 1, y - 1},
     {x + 0, y - 1},
     {x - 1, y - 1},
     {x - 1, y + 0},
     {x - 1, y + 1}]
  end

  def filter_mines(seed, tiles) do
    Enum.filter(tiles, fn tile -> mine?(seed, tile) end)
  end

  def make_mine, do: :mine
  def make_empty(count), do: {:empty, count}
end
