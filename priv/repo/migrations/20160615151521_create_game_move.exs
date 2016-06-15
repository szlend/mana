defmodule Mana.Repo.Migrations.CreateGameMove do
  use Ecto.Migration

  def change do
    create table(:game_moves) do
      add :pos_x, :integer
      add :pos_y, :integer
      add :game_id, references(:games, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps
    end
    create index(:game_moves, [:game_id])
    create index(:game_moves, [:user_id])

  end
end
