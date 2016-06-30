defmodule Mana.GameSupervisor do
  use Supervisor

  # Client

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def create_game(name) do
    Supervisor.start_child(__MODULE__, [name])
  end

  # Server

  def init(_) do
    children = [
      worker(Mana.GameInstance, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
