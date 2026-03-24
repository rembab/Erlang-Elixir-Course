-module(qsort).
-export([qs/1, random_elems/3, compare_speeds/3]).

less_than(List, Arg) -> [X || X <- List, X < Arg].

grt_eq_than(List, Arg) -> [X || X <- List, X >= Arg].


qs(A) ->
  case A of
    [] ->
      [];
    [Pivot|Tail] ->
      qs( less_than(Tail,Pivot) ) ++ [Pivot] ++ qs( grt_eq_than(Tail,Pivot) )
  end.


random_elems(N, Min, Max) -> [rand:uniform(Max - Min)+Min || _ <- lists:seq(1, N)].

compare_speeds(List, Fun1, Fun2) -> {element(1, timer:tc(Fun1, [List])), element(1, timer:tc(Fun2, [List]))}.
