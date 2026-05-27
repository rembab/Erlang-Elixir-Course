-module(pollution).
-export([create_monitor/0, add_station/3, add_value/5, remove_value/4, get_one_value/4, get_station_min/3, get_station_mean/3, get_daily_mean/3, get_correlation/3, get_station/2]).

-record(reading, {dateTime, type, value}).
-record(station, {name, coords, readings=[]}).

create_monitor() ->
  #{}.

has_station(NameOrCoords, Monitor) ->
  case maps:find(NameOrCoords, Monitor) of
    error -> 
      false;
    {ok, _} ->
      true
  end.

get_station(NameOrCoords, Monitor) ->
  case maps:find(NameOrCoords, Monitor) of
    error -> 
      {error, "No such station"};
    {ok, Station} ->
      Station
  end.

get_reading(DateTime, Type, Station) ->
  case [R || R <- Station#station.readings, R#reading.type =:= Type, R#reading.dateTime =:= DateTime] of
    [A] -> 
      {true, A};
    [] ->
      false
  end.

add_station(Name, Coords, Monitor) ->
  case has_station(Name, Monitor) or has_station(Coords, Monitor) of
    false ->
      Station = #station{coords = Coords, name = Name},
      Monitor#{Name => Station, Coords => Station};
    true ->
      {error, "Station with matching coordinates or name already exists"}
  end.

add_value(NameOrCoords, DateTime, Type, Value, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      case get_reading(DateTime, Type, Station) of
        {true, _} ->
          {error, "A reading value with same time and type already exists for this station"};
        false ->
          NewReadings = [#reading{type = Type, value = Value, dateTime = DateTime} | Station#station.readings],
          NewStation = Station#station{readings = NewReadings},
          Name = NewStation#station.name,
          Coords = NewStation#station.coords,
          Monitor#{Name := NewStation, Coords := NewStation}
      end
  end.

remove_value(NameOrCoords, DateTime, Type, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      io:format("f1\n"),
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      case get_reading(DateTime, Type, Station) of
        false ->
          {error, "A reading value at this time and of this type does not exists in this station's readings"};
        {true, R} ->
          NewReadings = lists:filter(fun (X) when X =:= R -> false; (_) -> true end, Station#station.readings),
          NewStation = Station#station{readings = NewReadings},
          Name = NewStation#station.name,
          Coords = NewStation#station.coords,
          Monitor#{Name := NewStation, Coords := NewStation}
      end
  end.

get_one_value(NameOrCoords, DateTime, Type, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      case get_reading(DateTime, Type, Station) of 
        {true, R} ->
          R#reading.value;
        false ->
          {error, "A reading value at this time and of this type does not exists in this station's readings"}
      end
  end.

get_station_min(NameOrCoords, Type, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      Xs = [X#reading.value || X <- Station#station.readings, X#reading.type =:= Type],
      case Xs of
        [] ->
          {error, "Station has no readings of aformentioned type"};
        [Head|Tail] ->
          lists:foldl(fun (X, Acc) -> min(X,Acc) end, Head, Tail)
      end
  end.

get_station_mean(NameOrCoords, Type, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      Xs = [X#reading.value || X <- Station#station.readings, X#reading.type =:= Type],
      case Xs of
        [] ->
          {error, "Station has no readings of aformentioned type"};
        [Head|Tail] ->
          lists:foldl(fun (X, Acc) -> X + Acc end, Head, Tail) / length(Xs)
      end
  end.
    
get_daily_mean(Type, Day, Monitor) ->
  Stations = maps:values(Monitor),
  Readings = lists:flatmap(fun(S) -> S#station.readings end, Stations),
  ReadingsInDay = lists:filter(fun 
                                 (R) when R#reading.type == Type, element(1, R#reading.dateTime) == Day -> true; 
                                 (_) -> false 
                               end, 
                               Readings),
  case ReadingsInDay of
    [] ->
      {error, "There are no readings of afermentioned type recorded that day"};
    [Head | Tail] ->
      lists:foldl(fun (X, Acc) -> X#reading.value + Acc end, Head#reading.value, Tail) / length(ReadingsInDay)
  end.

% dodaj do modułu funkcję get_correlation która obliczy odchylenie standardowe z różnic pomiarów dwóch typów zanieczyszczeń 

count_differences(SortedReadings) ->
  case SortedReadings of
    [#reading{type = T1, dateTime = D, value = V1}, #reading{type = T2, dateTime = D, value = V2} | Tail] when T1 =/= T2->
      [V2 - V1 | count_differences(Tail)];
    [_ | Tail] ->
      count_differences(Tail);
    [] -> 
      []
  end.
          
get_correlation(Type1, Type2, Monitor) ->
  Stations = lists:usort(maps:values(Monitor)),
  ReadingsByStation = lists:map(fun(S) -> S#station.readings end, Stations),
  ReadingsFiltered = lists:map(fun(Rs) -> lists:filter(fun(R) -> R#reading.type == Type1 orelse R#reading.type == Type2 end, Rs) end, ReadingsByStation),
  ReadingsSorted = lists:map(fun(Rs) -> lists:sort(Rs) end, ReadingsFiltered),
  case ReadingsSorted of 
    [] ->
      {error, "No readings with any of the two provided types"};
    _ ->
      Differences = lists:flatmap(fun count_differences/1 , ReadingsSorted),
      io:format("~p", [Differences]),
      case Differences of
        [] ->
          {error, "Readings of afermentioned types never coencide"};
        _ ->
          Mean = lists:sum(Differences) / length(Differences),
          DevSum = lists:foldl(fun (X, Acc) -> (X - Mean) * (X - Mean) + Acc end, 0, Differences),
          DevSq = DevSum / length(Differences),
          math:sqrt(DevSq)
      end
  end.

  
