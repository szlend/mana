defmodule Mana.Repo.Migrations.CreateGamePlayer do
  use Ecto.Migration

  def change do
    create table(:game_players) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :game_id, references(:games, on_delete: :delete_all)

      timestamps
    end

    create index(:game_players, [:user_id])
    create index(:game_players, [:game_id])

  end
end
