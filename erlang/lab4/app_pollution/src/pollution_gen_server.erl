-module(pollution_gen_server).

-behaviour(gen_server).

-export([start_link/0, init/1, crash/0, handle_cast/2, handle_call/3]).
-export([add_station/2, add_value/4, remove_value/3, get_one_value/3, get_station_min/2, get_station_mean/2, get_daily_mean/2, get_correlation/2, has_station/1]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_args) ->
  {ok, pollution:create_monitor()}.

crash() ->
  gen_server:cast(?MODULE, crash).

add_station(Name, Coords) ->
  gen_server:call(?MODULE,{add_station_msg,  [Name, Coords]}).

add_value(NameOrCoords, DateTime, Type, Value) ->
  gen_server:call(?MODULE,{add_value_msg, [NameOrCoords, DateTime, Type, Value]}).

remove_value(NameOrCoords, DateTime, Type) ->
  gen_server:call(?MODULE,{remove_value_msg, [NameOrCoords, DateTime, Type]}).

get_one_value(NameOrCoords, DateTime, Type) ->
  gen_server:call(?MODULE,{get_one_value_msg, [NameOrCoords, DateTime, Type]}).

has_station(NameOrCoords) ->
  gen_server:call(?MODULE, {has_station_msg, [NameOrCoords]}).

get_station_min(NameOrCoords, Type) ->
  gen_server:call(?MODULE,{get_station_min_msg, [NameOrCoords, Type]}).

get_station_mean(NameOrCoords, Type) ->
  gen_server:call(?MODULE,{get_station_mean_msg, [NameOrCoords, Type]}).

get_daily_mean(Type, Day) ->
  gen_server:call(?MODULE,{get_daily_mean_msg, [Type, Day]}).

get_correlation(Type1, Type2) ->
  gen_server:call(?MODULE,{get_correlation_msg, [Type1, Type2]}).


handle_call({Req, Args0}, _From, State) ->
  Args = Args0 ++ [State],
  Result = case Req of 
    add_station_msg ->
      {modify, apply(pollution, add_station, Args)};

    add_value_msg ->
      {modify, apply(pollution, add_value, Args)};

    remove_value_msg ->
      {modify, apply(pollution, remove_value, Args)};

    has_station_msg ->
      {get, apply(pollution, has_station, Args)};
    
    get_one_value_msg ->
      {get, apply(pollution, get_one_value, Args)};

    get_station_min_msg ->
      {get, apply(pollution, get_station_min, Args)};

    get_station_mean_msg ->
      {get, apply(pollution, get_station_mean, Args)};
    
    get_daily_mean_msg ->
      {get, apply(pollution, get_daily_mean, Args)};
    
    get_correlation_msg ->
      {get, apply(pollution, get_correlation, Args)}
  end,

  {Reply, NewState} = case Result of
    {_, {error, Msg}} -> 
      {{error, Msg}, State};    
    {get, Res} ->
      {Res, State};
    {modify, Res} ->
      {ok, Res}
  end,

  {reply, Reply, NewState}.

handle_cast(crash, State) ->
  1/0,
  {noreply, State}.

