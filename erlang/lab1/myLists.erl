-module(myLists).
-export([contains/2, duplicateElements/1, sumFloats/1]).

contains(X,L) ->
  case {X,L} of
    {X,[X|_]} ->
      true;
    {X,[]} ->
      false;  
    {X, [_|A]} ->
      contains(X,A)
  end.

duplicateElements(L) ->
  case L of
    [] -> 
      [];
    [X|A] ->
      [X,X]++duplicateElements(A)
  end.

sumFloats(L) ->
  case L of
    [] ->
      0;
    [X|A] when is_float(X) ->
      X + sumFloats(A);
    [X|A] ->
      sumFloats(A)
  end.

