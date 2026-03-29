-module(pollution).
-export([create_monitor/0, add_station/3, add_value/5, remove_value/4, get_one_value/4]).

-record(reading, {dateTime, type, value}).
-record(station, {name, coords, readings=[]}).

create_monitor() ->
  #{}.

has_station(NameOrCoords, Monitor) ->
  case maps:find(NameOrCoords, Monitor) of
    {error, _} -> 
      false;
    {ok, _} ->
      true
  end.

get_reading(DateTime, Type, Station) ->
  case [R || R <- Station#station.readings, R#reading.type =:= Type, R#reading.dateTime =:= DateTime] of
    [R] -> 
      {true, R};
    [] ->
      false
  end.


add_station(Name, Coords, Monitor) ->
  case has_station(Name, Monitor) or has_station(Coords, Monitor) of
    false ->
      Station = #station{coords = Coords, name = Name},
      Monitor#{Name := Station, Coords := Station};
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
          NewReadings = Station#station.readings ++ #reading{type = Type, value = Value, dateTime = DateTime},
          Monitor#{Station := Station#station{readings = NewReadings}}
      end
  end.


remove_value(NameOrCoords, DateTime, Type, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      case get_reading(DateTime, Type, Station) of
        false ->
          {error, "A reading value at this time and of this type does not exists in this station's readings"};
        {true, R} ->
          NewReadings = lists:filter(fun (R) -> true; (_) -> false end, Station#station.readings),

          Monitor#{Station := Station#station{readings = NewReadings}}
      end
  end.


get_one_value(NameOrCoords, Type, DateTime, Monitor) ->
  case has_station(NameOrCoords, Monitor) of  
    false ->
      {error, "No station with such name or coordinates"};
    true ->
      #{NameOrCoords := Station} = Monitor, 
      case lists:search(fun 
                          (#reading{type = T, dateTime = DT}) when T =:= Type, DT =:= DateTime -> 
                            true; 
                          (_) -> 
                        false end,
                        Station#station.readings) of
        {value, Value} ->
          Value;
        false ->
          {error, "A reading value at this time and of this type does not exists in this station's readings"}
      end
  end.

get_station_min(NameOrCoords)




