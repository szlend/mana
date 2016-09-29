defmodule Mana do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Mana.Repo, []),
      supervisor(Mana.Endpoint, []),
      supervisor(Mana.GridSupervisor, []),
    ]

    move_tracker = worker(Mana.MoveTracker, [])
    opts = [strategy: :one_for_one, name: Mana.Supervisor]

    if Application.fetch_env!(:mana, :move_tracker) do
      Supervisor.start_link([move_tracker | children], opts)
    else
      Supervisor.start_link(children, opts)
    end
  end

  def config_change(changed, _new, removed) do
    Mana.Endpoint.config_change(changed, removed)
    :ok
  end
end
