defmodule Mana.UserSocket do
  use Phoenix.Socket
  import Guardian.Phoenix.Socket

  ## Channels
  channel "game:*", Mana.GameChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    case sign_in(socket, token) do
      {:ok, socket, _} ->
        user = current_resource(socket)
        {:ok, socket |> assign(:id, user.id)}
      _ ->
        :error
    end
  end

  def id(socket) do
    Integer.to_string(socket.assigns.id)
  end
end
