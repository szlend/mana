defmodule Mana.Board do
  def make_mine, do: :mine
  def make_empty(count), do: {:empty, count}

  def mine?(seed, {x, y}) do
    rem(:erlang.phash2({seed, x, y}), 1000) > 800
  end

  def reveal(seed, moves, tile) do
    if mine?(seed, tile) do
      %{tile => make_mine()}
    else
      reveal_empty(seed, moves, Map.new, tile)
    end
  end

  def reveal_empty(seed, moves, new_moves, tile) do
    if Map.has_key?(new_moves, tile) or Map.has_key?(moves, tile) do
      new_moves
    else
      count = adjacent_mines(seed) |> Enum.count
      tiles = next_tiles(tile)
      new_moves = Map.put(new_moves, tile, make_empty(count))

      if count == 0 do
        Enum.reduce(tiles, new_moves,
          fn tile, new_moves -> reveal_empty(seed, moves, new_moves, tile) end)
      else
        new_moves
      end
    end
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

  def next_tiles({x, y}) do
    [{x + 0, y + 1},
     {x + 1, y + 0},
     {x + 0, y - 1},
     {x - 1, y + 0}]
  end

  def adjacent_mines(seed, tile) do
    adjacent_tiles(tile)
    |> Enum.filter(fn tile -> mine?(seed, tile) end)
  end

  def serialize_moves(moves) do
    Enum.map(moves, fn {{x, y}, move} -> [x, y, serialize_move(move)] end)
  end

  def serialize_moves(moves, {x, y}, {w, h}) do
    {p1, p2} = {{x, y}, {x + w, y + h}}
    Enum.filter_map(moves,
      fn {{x, y}, _} -> between_points?({x, y}, p1, p2) end,
      fn {{x, y}, move} -> [x, y, serialize_move(move)] end)
  end

  def serialize_mines(seed, {x, y}, {w, h}) do
    {xs, ys} = {x..x+w-1, y..y+h-1}
    for x <- xs, y <- ys, mine?(seed, {x, y}), do: [x, y]
  end

  def serialize_move(:mine), do: 9
  def serialize_move({:empty, count}), do: count

  def between_points?({x, y}, {x1, y1}, {x2, y2}) do
    x >= x1 and x < x2 and y >= y1 and y < y2
  end
end
