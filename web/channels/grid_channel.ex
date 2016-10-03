defmodule Mana.GridChannel do
  use Mana.Web, :channel
  alias Mana.{Board, Grid, Serializer}

  def join("grid:" <> grid, _payload, socket) do
    {x, y} = parse_coordinates(grid)
    if Grid.valid_position?({x, y}) do
      moves = Grid.moves({x, y}) |> Serializer.moves
      mines = get_mines({x, y}) |> Serializer.mines
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

  def get_mines({x, y}) do
    if Application.fetch_env!(:mana, :grid_flags) do
      Board.mines(Grid.seed(), {x, y}, Grid.size())
    else
      []
    end
  end
end
