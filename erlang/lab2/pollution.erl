-module(pollution).
-export([create_monitor/0, add_station/3, add_value/5, remove_value/4, get_one_value/4, get_station_min/3, get_station_mean/3, get_daily_mean/3]).

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
      Xs = [X || X <- Station#station.readings, X#reading.type =:= Type],
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
  Readings = lists:foldl(fun (R, Acc) -> [R#station.readings] ++ Acc end, [], Stations),
  ReadingsInDay = lists:filter(fun 
                                 (R) when R#reading.type == Type, element(1, R#reading.dateTime) == Day
                                          -> true; 
                                 (_) 
                                 -> false end, Readings),
  io:format("~p", length(ReadingsInDay)),
  lists:foldl(fun (X, Acc) -> X#reading.value + Acc end, 0, ReadingsInDay) / length(ReadingsInDay).




