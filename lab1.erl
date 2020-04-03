%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Mar 2020 10:26 AM
%%%-------------------------------------------------------------------
-module(lab1).
-author("andrz").

%% API
-export([power/2]).

power(A, 0) -> 1;
power(A,N) -> A*power(A, N-1).
