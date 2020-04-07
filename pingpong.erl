%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Apr 2020 7:22 PM
%%%-------------------------------------------------------------------
-module(pingpong).
-author("andrz").

%% API
-export([start/0, stop/0, play/1, pingFun/0, pongFun/0]).


start() ->
  register (ping, spawn (?MODULE, pingFun, [])),
  register (pong, spawn(?MODULE, pongFun, [])),
  ok.

play(N) ->
  pong ! start,
  ping ! N,
  ok.


stop() ->
  ping ! stop,
  pong ! stop.

pingFun() ->
  receive
    stop -> ok;
    N -> sendNMsg(N), pingFun()
  end.

pongFun() ->
  receive
    stop -> ok;
    start -> receiveAndResponse(), pongFun()
  end.


sendNMsg(0)-> pong ! term, ok;
sendNMsg(N) ->
  io:format("Ping sending: ~B~n",[N]),
  pong !  N,
  receive
    M->io:format("Ping received: ~B~n~n",[M]),
      timer:sleep(1000),
      sendNMsg(N-1)
  end.

receiveAndResponse()->
  receive
    term -> ok;
    N->io:format("Pong received: ~B~n",[N]),
      io:format("Pong sending: ~B~n",[N]),
      ping ! N,
      receiveAndResponse()
  end.


