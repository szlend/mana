defmodule Mana do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Mana.Repo, []),
      supervisor(Mana.Endpoint, []),
      supervisor(Mana.GridSupervisor, [])
      # worker(Mana.MoveTracker, [])
    ]

    opts = [strategy: :one_for_one, name: Mana.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Mana.Endpoint.config_change(changed, removed)
    :ok
  end
end
