defmodule Mana.MoveTracker do
  use GenServer

  @score_multiplier 100
  @mine_points -50
  @multi_reveal_points 1

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def move(user_id, tile, moves) do
    GenServer.call(__MODULE__, {:move, user_id, tile, moves})
  end

  def last_move() do
    GenServer.call(__MODULE__, :last_move)
  end

  # Server

  def init(_) do
    {:ok, %{last_move: nil, scores: %{}}}
  end

  def handle_call({:move, user_id, tile, moves}, _from, state) do
    state = accumulate_score(state, user_id, tile, moves)
    state = %{state | last_move: {user_id, tile}}
    score = state.scores[user_id]
    {:reply, {:ok, score}, state}
  end

  def handle_call(:last_move, _from, state) do
    {:reply, {:ok, state.last_move}, state}
  end

  def accumulate_score(state, user_id, tile, moves) do
    score = state.scores[user_id] || 0
    scores = Map.put(state.scores, user_id, score + points(moves[tile]))
    %{state | scores: scores}
  end

  def points(:mine), do: @mine_points * @score_multiplier
  def points({:empty, 0}), do: @multi_reveal_points * @score_multiplier
  def points({:empty, n}), do: n * @score_multiplier
end
