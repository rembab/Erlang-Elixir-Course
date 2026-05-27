-module(pollution_value_collector_gen_statem).

-behaviour(gen_statem).

-export([init/1, callback_mode/0, start_link/0]).
-export([adding/3, set_station/1, selecting/3]).

start_link() ->
  gen_statem:start_link({local, ?MODULE}, ?MODULE, []).

set_station(NameOrCoords) ->
  case pollution_gen_server:get_station(NameOrCoords)  of
    {error, Msg} -> 
      {error, Msg};
    Station ->
      gen_statem:call(?MODULE, {station, Station})
  end.

callback_mode() -> state_functions.

init(_Args) ->
  {ok, selecting, {}}.


selecting(call, {station, Station}, _Data) -> 
  {next_state, adding, {Station, []}}.

adding(call, {add, DateTime, Type, Value}, {Station, Values}) ->
  {next_state, adding, {Station, Values ++ [{DateTime, Type, Value}]}};

adding(call, store, {Station,Values}) ->
  lists:foreach(fun ({DateTime, Type, Value}) -> pollution_gen_server:add_value(Station, DateTime, Type, Value) end, Values),
  {next_state, selecting, {}}.




