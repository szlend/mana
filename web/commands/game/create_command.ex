defmodule Mana.Game.CreateCommand do
  use Mana.Web, :command

  def run(name) when is_binary(name) do
    case Mana.GameSupervisor.create_game(name) do
      {:ok, game} ->
        :ok

      {:error, _} ->
        :error
    end
  end
end