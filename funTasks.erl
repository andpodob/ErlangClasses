%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. Mar 2020 7:03 PM
%%%-------------------------------------------------------------------
-module(funTasks).
-author("andrz").

%% API
-export([map/2, filter/2, digitsSum/1, digSumdivByThree/1]).

map(_, []) -> [];
map(Fun, [H|T])->[Fun(H)|map(Fun, T)].

filter(Pred, List) -> [X || X<-List, Pred(X)].

digitsSum(N) when is_integer(N) -> lists:foldl(fun(N, Acc)->N+Acc end, 0, [list_to_integer([C]) || C <- integer_to_list(N)]).

digSumdivByThree(List) -> lists:filter(fun(N)->(N rem 3 == 0)end, List).