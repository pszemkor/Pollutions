%%%-------------------------------------------------------------------
%%% @author Acer
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. maj 2019 13:25
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Acer").

%% API
-export([start/0, stop/0, addStation/2, addValue/4, removeValue/3,
  getOneValue/3, getStationMean/2, getDailyMean/2, getMinMaxValue/3]).

start() ->
  ServerPID = spawn(fun() -> init() end),
  register(server, ServerPID),
  ServerPID.

stop() ->
  server ! terminate.

init() ->
  loop(pollution:createMonitor()).

loop(MonitorState) ->
  receive
    terminate -> ok;
    {request, PID, {addStation, Name, Coords}} ->
      NextState = pollution:addStation(Name, Coords, MonitorState),
      PID ! {reply, NextState},
      loop(NextState);
    {request, PID, {addValue, Key, Date, Type, Value}} ->
      NextState = pollution:addValue(Key, Date, Type, Value, MonitorState),
      PID ! {reply, NextState},
      loop(NextState);
    {request, PID, {removeValue, Key, Date, Type}} ->
      NextState = pollution:removeValue(Key, Date, Type, MonitorState),
      PID ! {reply, NextState},
      loop(NextState);
    {request, PID, {getOneValue, Key, Date, Type}} ->
      Val = pollution:getOneValue(Key, Date, Type, MonitorState),
      PID ! {reply, Val},
      loop(MonitorState);
    {request, PID, {getStationMean, Key, Type}} ->
      Val = pollution:getStationMean(Key, Type, MonitorState),
      PID ! {reply, Val},
      loop(MonitorState);
    {request, PID, {getDailyMean, Day, Type}} ->
      Val = pollution:getDailyMean(Day, Type, MonitorState),
      PID ! {reply, Val},
      loop(MonitorState);
    {request, PID, {getMinMaxValue, Coords, Day, Type}} ->
      Val = pollution:getMinMaxValue(Coords, Day, Type, MonitorState),
      PID ! {reply, Val},
      loop(MonitorState)
  end.

call(Msg) ->
  server ! {request, self(), Msg},
  receive
    {reply, Reply} -> Reply
  end.


addStation(Name, Coords) ->
  call({addStation, Name, Coords}).

addValue(Key, Date, Type, Value) ->
  call({addValue, Key, Date, Type, Value}).

removeValue(Key, Date, Type) ->
  call({removeValue, Key, Date, Type}).

getOneValue(_Arg0, _Arg1, _Arg2) ->
  erlang:error(not_implemented).

getStationMean(_Arg0, _Arg1) ->
  erlang:error(not_implemented).

getDailyMean(_Arg0, _Arg1) ->
  erlang:error(not_implemented).

getMinMaxValue(_Arg0, _Arg1, _Arg2) ->
  erlang:error(not_implemented).