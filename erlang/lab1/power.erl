-module(power).

-export([power/2]).

power(N, E) ->
  case {N, E} of
    {N, 0} ->
      1;
    {0, E} ->
      0;
    {1, E} ->
      1;
    {N, E} ->
      N * power(N, E - 1)
  end.
