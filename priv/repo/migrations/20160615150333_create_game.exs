defmodule Mana.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nilify_all)
      add :status, :string

      timestamps
    end

    create index(:games, [:user_id])
  end
end
