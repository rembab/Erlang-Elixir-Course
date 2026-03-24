-module(weather).
-export([random_dataset/1, number_of_readings/2, calculate_min_and_max/2, calculate_mean/2]).

random_char( ) -> 
  rand:uniform(26) + 64.

random_date() ->
  {rand:uniform(30), rand:uniform(12), 2000}.

random_time() ->
  {rand:uniform(24), rand:uniform(60)-1}.

random_string(N) -> 
  case N of 
    0 -> 
      [ ]; 
    _ -> 
      [random_char( )] ++ random_string(N-1)
  end.

reading_types() -> {"PM10", "PM2.5", "PM5", "PM1"}.

random_type() -> element(rand:uniform(tuple_size(reading_types())), reading_types()).

random_reading() ->
  {random_type(),rand:uniform()*200}.

random_reading_list(N) ->
  case N of
    0 ->
      [];
    _ ->
      [random_reading()] ++ random_reading_list(N-1)
  end.

random_station_data(NReadings) ->
  {random_string(5), random_date(), random_time(), random_reading_list(NReadings)}.

random_dataset(NStations) ->
  case NStations of
    0 ->
      [];
    _ ->
      [random_station_data(rand:uniform(3))] ++ random_dataset(NStations-1)
  end.

extract_readings(Readings, Type) ->
  case Readings of
    [] ->
      [];
    [S|R] ->
      [element(2,X) || X <-element(4, S), element(1, X) == Type] ++ extract_readings(R, Type);
    _ ->
      []
  end.

number_of_readings(Readings, Date) -> 
  length([X || X <- Readings, element(2,X) == Date]).                                 

calculate_min_and_max(Readings,Type) -> 
  R = extract_readings(Readings, Type),
  {lists:foldl(fun(X,Min) -> min(X,Min) end, lists:nth(1, R), R), 
   lists:foldl(fun(X,Max) -> max(X,Max) end, lists:nth(1, R), R)}.

calculate_mean(Readings, Type) ->
  R = extract_readings(Readings, Type),
  lists:foldl(fun(X,Sum) -> X + Sum end, 0, R) / length(R).
  
