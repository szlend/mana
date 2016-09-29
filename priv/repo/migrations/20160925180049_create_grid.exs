defmodule Mana.Repo.Migrations.CreateGrid do
  use Ecto.Migration

  def change do
    create table(:grids) do
      add :seed, :integer
      add :size, :integer
      add :x, :bigint
      add :y, :bigint
      add :revealed, :integer
      add :data, :binary
    end

    create index(:grids, [:seed, :size, :x, :y], unique: true)
  end
end
