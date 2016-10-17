# Mana
### A distributed Minesweeper MMO

The game was built in collaboration with
[@usoban](https://github.com/usoban)
and
[@janhorvat](https://github.com/janhorvat)
over the summer,
as a learning project and a tech demo of what Elixir and Phoenix are capable of.

![Screenshot](/screenshot.png?raw=true "Screenshot")

### Procedurally generated
The mines are procedurally generated with a simple hash function. This allows us
to have a practically infinite playable minefield because we don't have to 
generate the mines in advance. We can compute if a mine is there given just
coordinates `x`, `y` and the `seed`.

### Distributed grid
The infinite map is split into 50x50 grids by default. Each grid section is it's
own `GenServer`, and is responsible for it's own state (saving tile reveals).
The grids are spawned lazily as players scroll into it's view, and they are put
to sleep and persist their state in the database after inactivity or a crash.

This design has many advantages:
- It allows us to scale horizontally by distributing the grids among nodes
- It gives us fault tolerance by isolating errors only to that section
- It partitions the grids so that players are only subscribed to parts of the
map that's visible to them
- It doesn't have to query the database every time a move is made

### Possible improvements
- Add flags (right click)
- A single node is responsible for tracking ALL player scores. I think a better
way would be to have each node be responsible for it's own players' scores
- Player scores are not persisted in the database
- Net-splits and topology changes are not handled, so some data loss may occur
- Rendering in JavaScript breaks down above `MAX_SAFE_INTEGER`. This shouldn't
be too hard to fix by using some implementation of BigInt, and clamping the
rendering coordinates
- Use some form of compression for streaming in large number of moves
