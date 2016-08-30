defmodule Mana.Repo.Migrations.DropOldTables do
  use Ecto.Migration

  def change do
    drop table(:game_moves)
    drop table(:game_players)
    drop table(:games)
    drop table(:users)
  end
end
