defmodule Mana.User do
  @grid_limit 8

  def start_link(id, name) do
    state = %{id: id, name: name, grids: []}
    Agent.start_link(fn -> state end)
  end

  def name(user) do
    Agent.get(user, fn state -> state.name end)
  end

  def register_grid(user, grid) when is_pid(grid) do
    Agent.update(user, fn(state) -> add_grid(state, grid) end)
  end

  defp add_grid(%{grids: grids} = state, grid)
  when length(grids) == @grid_limit do
    {grids, [last_grid]} = Enum.split([grid | grids], @grid_limit)
    send(last_grid, :leave)
    %{state | grids: grids}
  end

  defp add_grid(%{grids: grids} = state, grid) do
    %{state | grids: [grid | grids]}
  end
end
