defmodule Mana.GridChannel do
  use Mana.Web, :channel
  alias Mana.{Board, Grid, Serializer}

  def join("grid:" <> grid, _payload, socket) do
    {x, y} = parse_coordinates(grid)
    if Grid.valid_position?({x, y}) do
      moves = Grid.moves({x, y}) |> Serializer.moves
      mines = Board.mines(Grid.seed(), {x, y}, Grid.size()) |> Serializer.mines
      {:ok, %{x: x, y: y, moves: moves, mines: mines}, socket}
    else
      {:error, %{reason: "Invalid grid position"}, socket}
    end
  end

  defp parse_coordinates(grid) do
    [_, x, y] = Regex.run(~r/^(-?[0-9]+):(-?[0-9]+)$/, grid)
    {{x, _}, {y, _}} = {Integer.parse(x), Integer.parse(y)}
    {x, y}
  end
end
