%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Mar 2020 6:12 PM
%%%-------------------------------------------------------------------
-module(quickSort).
-author("andrz").

%% API
-export([lessThan/2, grtEqThan/2, randomElemens/3, compareSpeeds/3, qs/1]).

lessThan(List, Arg)->[X || X <- List, X < Arg].
grtEqThan(List, Arg) -> [X || X <- List, X >= Arg].

qs([]) -> [];
qs([Pivot|Tail]) -> qs( lessThan(Tail,Pivot) ) ++ [Pivot] ++ qs( grtEqThan(Tail,Pivot) ).

randomElemens(N, Min, Max) -> [random:uniform(Max-Min+1)+Min-1 || _ <- lists:seq(1, N)].

compareSpeeds(List, Fun1, Fun2)->
  {T2,_} = timer:tc(Fun2,[List]),
  {T1,_} = timer:tc(Fun1,[List]),
  io:fwrite("Fun1: ~w Fun2: ~w~n", [T1,T2]).


