defmodule Mana.UserSocket do
  use Phoenix.Socket
  alias Mana.User

  ## Channels
  channel "game", Mana.GameChannel
  channel "grid:*", Mana.GridChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    socket = assign(socket, :token, token)
    {:ok, socket}
  end

  def id(_socket), do: nil
end
