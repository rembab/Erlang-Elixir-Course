%%%-------------------------------------------------------------------
%% @doc app_pollution public API
%% @end
%%%-------------------------------------------------------------------

-module(app_pollution_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    app_pollution_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
