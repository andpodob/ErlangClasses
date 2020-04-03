%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Mar 2020 10:33 AM
%%%-------------------------------------------------------------------
-module(myList).
-author("andrz").

%% API
-export([contains/2, duplicateElements/1, sumFloatsTail/1, sumFloats/1]).

contains([], _) -> false;
contains([H|_], H)->true;
contains([_|T], X)->contains(T, X).

duplicateElements([]) -> [];
duplicateElements([H|T]) -> [H,H]++duplicateElements(T).

sumFloats([]) -> 0;
sumFloats([H|T]) when is_float(H) -> H + sumFloats(T);
sumFloats([H|T]) -> sumFloats(T).

sumFloatsTail(L) -> sumFloatsWithAcc(L, 0).

sumFloatsWithAcc([], Acc)->Acc;
sumFloatsWithAcc([H|T], Acc) when is_float(H) -> sumFloatsWithAcc(T, Acc+H);
sumFloatsWithAcc([H|T], Acc) -> sumFloatsWithAcc(T, Acc).