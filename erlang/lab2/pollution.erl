-module(pollution).
-export([create_monitor/0, add_station/3]).

-record(reading, {date, time, type, value}).
-record(station, {name, coords, readings=[]}).

create_monitor() ->
  [].

has_station(Station, Monitor) ->
  case Monitor of
    [#station{name = Station#station.name} | _] ->
      true;
    [#station{coords = Station#station.coords} | _] ->
      true;
    [] ->
      false;
    [_|_M] ->
      has_station(_M, Station)
  end.


add_station(Name, Coords, Monitor) ->
  Monitor ++ #station{name=Name, coords=Coords}.




