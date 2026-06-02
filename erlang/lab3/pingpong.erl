-module(pingpong).
-export ([start/0, stop/0, play/1]).

start() ->
  register(pong, spawn(fun pong/0)),
  register(ping, spawn(fun () -> ping(0) end)).

ping(State) ->
  receive
    stop ->
      ok;
    N when N > 0 ->
      State1 = N + State,
      io:format("Ping ~w Sum: ~w ~n", [N, State1]),
      timer:sleep(100),
      pong ! (N - 1),
      ping(State1)
  after
    20000 -> 
      ok
  end.

pong() ->
  receive
    stop ->
      ok;
    N when N > 0 ->
      io:format("Pong ~w ~n", [N]),
      timer:sleep(100),
      ping ! (N - 1),
      pong()
    after
    20000 -> 
      ok
  end.

play(N) ->
  ping ! N.

stop() ->
  spawn(
  fun () ->
    ping ! stop,
    pong ! stop
  end).


