defmodule Mana.GridState do
  alias Mana.Repo
  import Ecto.Query, only: [from: 2]

  def save(%{seed: seed, size: size, from: {x, y}, moves: moves}) do
    unique_data = [seed: seed, size: size, x: x, y: y]
    data = {:data, :erlang.term_to_binary(moves)}
    Repo.insert_all("grids", [[data | unique_data]],
      on_conflict: [set: [data]],
      conflict_target: [:seed, :size, :x, :y])
  end

  def load(state) do
    case fetch_from_database(state) do
      %{data: data} -> %{state | moves: :erlang.binary_to_term(data)}
      nil -> state
    end
  end

  def fetch_from_database(%{seed: seed, size: size, from: {x, y}}) do
    Repo.one(from "grids",
      select: [:data],
      where: [seed: ^seed, size: ^size, x: ^x, y: ^y])
  end
end
