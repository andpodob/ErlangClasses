%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Apr 2020 9:17 PM
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("andrz").

%% API
-export([addStation/2, addValue/4, removeValue/3, getStationMedian/2, getStationMean/2, getOneValue/3, getDailyMean/3, getDailyMax/2, stop/0, start/0]).
-export([init/0]).
%[createMonitor/0, addStation/3, addValue/5, removeValue/4, getStationMean/3, getOneValue/4, getDailyMean/3, getStationMedian/3, getDailyMax/3])
%client
%%createMonitor()->

addStation(Name, Cords)->
  pollutionServer ! {request, self(), addStation, {Name, Cords}},
  receive
    {reply, Reply} -> Reply
  end.

addValue(NameOrCords, Time, Type, Val)->
  pollutionServer ! {request, self(), addStation, {NameOrCords, Time, Type, Val}},
  receive
    {reply, Reply} -> Reply
  end.

removeValue(NameOrCords, Time, Type)->
  pollutionServer ! {request, self(), addStation, {NameOrCords, Time, Type}},
  receive
    {reply, Reply} -> Reply
  end.

getStationMean(NameOrCords, Type)->
  pollutionServer ! {request, self(), addStation, {NameOrCords, Type}},
  receive
    {reply, Reply} -> Reply
  end.

getOneValue(NameOrCords, Date, Type)->
  pollutionServer ! {request, self(), getOneValue, {NameOrCords, Date, Type}},
  receive
    {reply, Reply} -> Reply
  end.

getDailyMean(Type, Day, Monitor)->
  pollutionServer ! {request, self(),  getDailyMean, {Type, Day, Monitor}},
  receive
    {reply, Reply} -> Reply
  end.

getStationMedian(NameOrCords,Type)->
  pollutionServer ! {request, self(), getStationMedian, {NameOrCords,Type}},
  receive
    {reply, Reply} -> Reply
  end.

getDailyMax(Type, Day)->
  pollutionServer ! {request, self(), getDailyMax, {Type, Day}},
  receive
    {reply, Reply} -> Reply
  end.

stop()->
  pollutionServer ! {request, self(), stop},
  receive
    {reply, Reply} -> Reply
  end.
%server

start() ->
  register (pollutionServer, spawn(?MODULE, init, [])),
  ok.

init()->
  loop(pollution:createMonitor()).

loop(Monitor)->
  receive
    {request, Pid, addStation, {Name, Cords}} ->
      P = pollution:addStation(Name, Cords, Monitor),
      Pid ! {reply, ok},
      loop(P);
    {request, Pid, addValue, {NameOrCords, Time, Type, Val}} ->
      P = pollution:addValue(NameOrCords, Time, Type, Val, Monitor),
      Pid ! {reply, ok},
      loop(P);
    {request, Pid, removeValue, {NameOrCords, Time, Type}}->
      P = pollution:removeValue(NameOrCords, Monitor, Time, Type),
      Pid ! {reply, ok},
      loop(P);
    {request, Pid, getStationMean, {NameOrCords, Type}}->
      Pid ! {reply, pollution:getStationMean(NameOrCords, Type, Monitor)},
      loop(Monitor);
    {request, Pid, getOneValue, {NameOrCords, Date, Type}}->
      Pid ! {reply, pollution:getOneValue(NameOrCords, Date, Type, Monitor)},
      loop(Monitor);
    {request, Pid, getDailyMean, {Type, Day}}->
      Pid ! {reply, pollution:getDailyMean(Type, Day, Monitor)},
      loop(Monitor);
    {request, Pid, getStationMedian, {NameOrCords,Type}}->
      Pid ! {reply, pollution:getStationMedian(NameOrCords, Type, Monitor)},
      loop(Monitor);
    {request, Pid, getDailyMax, {Type, Day}}->
      Pid ! {reply, pollution:getStationMedian(Type, Day, Monitor)},
      loop(Monitor);
    {request, Pid, stop}->
      Pid ! {reply, ok}
  end.
