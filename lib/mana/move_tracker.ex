defmodule Mana.MoveTracker do
  use GenServer
  alias Mana.{User, Serializer, Endpoint}

  @score_multiplier 1
  @mine_points -50
  @multi_reveal_points 1

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: via_global)
  end

  def via_global(), do: {:via, :global, :move_tracker}

  def move(user, tile, type) do
    GenServer.call(via_global, {:move, user, tile, type})
  end

  def last_move() do
    GenServer.call(via_global, :last_move)
  end

  # Server

  def init(_) do
    {:ok, %{last_move: nil, scores: %{}, top_scores: []}}
  end

  def handle_call({:move, user, tile, type}, _from, state) do
    new_scores = update_score(state.scores, user, type)

    # send the user their new scores
    User.send_score(User.via_name(user), new_scores[user])

    # broadcast new best scores if changed
    top_scores = top_scores(new_scores)
    if state.top_scores != top_scores do
      Endpoint.broadcast!("game", "scores", %{scores: Serializer.scores(top_scores)})
    end

    state = %{state | last_move: tile, scores: new_scores, top_scores: top_scores}
    {:reply, :ok, state}
  end


  def handle_call(:last_move, _from, state) do
    {:reply, state.last_move, state}
  end

  def top_scores(scores) do
    scores
    |> Enum.sort(fn {_, score1}, {_, score2} -> score1 > score2 end)
    |> Enum.take(6)
  end

  def update_score(scores, user, type) do
    score = scores[user] || 0
    Map.put(scores, user, score + points(type))
  end

  def points(:mine), do: @mine_points * @score_multiplier
  def points({:empty, 0}), do: @multi_reveal_points * @score_multiplier
  def points({:empty, n}), do: n * @score_multiplier
end
