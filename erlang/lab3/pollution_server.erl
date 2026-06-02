-module(pollution_server).
-export([start/0, stop/0, add_station/2, add_value/4, remove_value/3, get_one_value/3, get_station_min/2, get_station_mean/2, get_daily_mean/2, get_correlation/2]).

start() -> 
  PID = self(),
  spawn(fun () -> start_slave(PID) end),
  receive
    ok ->
      ok
  after
    100 ->
      {error, "Couldn't start server, make sure it's not already running"}
  end.
  

start_slave(PID) -> 
  register(pollution_server_process, spawn(fun init/0)),
  PID ! ok.


init() ->
    M = pollution:create_monitor(),
    loop(M).

sender_slave(Message) ->
  spawn( fun () -> pollution_server_process ! Message end).


add_station(Name, Coords) ->
  sender_slave({add_station_msg, self(), Name, Coords}),
  return_result().


add_value(NameOrCoords, DateTime, Type, Value) ->
  sender_slave({add_value_msg, self(), NameOrCoords, DateTime, Type, Value}),
  return_result().  


remove_value(NameOrCoords, DateTime, Type) ->
  sender_slave({remove_value_msg, self(), NameOrCoords, DateTime, Type}),
  return_result().

  
get_one_value(NameOrCoords, DateTime, Type) ->
  sender_slave({get_one_value_msg, self(), NameOrCoords, DateTime, Type}),
  return_result().


get_station_min(NameOrCoords, Type) ->
  sender_slave({get_station_min_msg, self(), NameOrCoords, Type}),
  return_result().


get_station_mean(NameOrCoords, Type) ->
  sender_slave({get_station_mean_msg, self(), NameOrCoords, Type}),
  return_result().


get_daily_mean(Type, Day) ->
  sender_slave({get_daily_mean_msg, self(), Type, Day}),
  return_result().

get_correlation(Type1, Type2) ->
  sender_slave({get_correlation_msg, self(), Type1, Type2}),
  return_result().

return_result() ->
  receive
    M ->
      M
  after 
    100 ->
      {error, "Timed out, make sure the server has been started"}
  end.


loop(M) ->
  Result = receive
    {add_station_msg, Sender, Name, Coords} ->
      {modify, Sender, pollution:add_station(Name, Coords, M)};

    {add_value_msg, Sender, NameOrCoords, DateTime, Type, Value} ->
      {modify, Sender, pollution:add_value(NameOrCoords, DateTime, Type, Value, M)};

    {remove_value_msg, Sender, NameOrCoords, DateTime, Type} ->
      {modify, Sender, pollution:remove_value(NameOrCoords, DateTime, Type, M)};
    
    {get_one_value_msg, Sender, NameOrCoords, DateTime, Type} ->
      {get, Sender, pollution:get_one_value(NameOrCoords, DateTime, Type, M)};

    {get_station_min_msg, Sender, NameOrCoords, Type} ->
      {get, Sender, pollution:get_station_min(NameOrCoords, Type, M)};

    {get_station_mean_msg, Sender, NameOrCoords, Type} ->
      {get, Sender, pollution:get_station_mean(NameOrCoords, Type, M)};
    
    {get_daily_mean_msg, Sender, Type, Day} ->
      {get, Sender, pollution:get_daily_mean(Type, Day, M)};
    
    {get_correlation_msg, Sender, Type1, Type2} ->
      {get, Sender, pollution:get_correlation(Type1, Type2, M)};
    
    {stop, Sender} ->
      {stop, Sender}
  end,

  case Result of
    {_, PID, {error, Msg}} ->
      PID ! {error, Msg},
      loop(M);
    {get, PID, Res} ->
      PID ! Res, 
      loop(M);
    {modify, PID, NewM} ->
      PID ! ok,
      loop(NewM);
    {stop, PID} ->
      PID ! ok
  end.


stop() ->
  sender_slave({stop, self()}),
  return_result().



