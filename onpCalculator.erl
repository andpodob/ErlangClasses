%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Mar 2020 2:03 PM
%%%-------------------------------------------------------------------
-module(onpCalculator).
-author("andrz").

%% API
-export([rpn/1]).


read(X) ->
  case string:to_float(X) of
    {error, _} -> list_to_integer(X);
    {F, _} -> F
  end.


rpn(L) when is_list(L) ->
  [Res] = lists:foldl(fun rpn/2, [], string:tokens(L, " ")),
  Res.

rpn("+", [N1, N2 | Stack]) -> [N2 + N1 | Stack];
rpn("-", [N1, N2 | Stack]) -> [N2 - N1 | Stack];
rpn("/", [N1, N2 | Stack]) ->
  case N1 of
    0 -> throw({error, division_by_zero});
    _ -> [N2/N1 | Stack]
  end;
rpn("*", [N1, N2 | Stack]) -> [N2 * N1 | Stack];
rpn("sin", [N1 | Stack])->[ math:sin(N1) | Stack ];
rpn("cos", [N1 | Stack])->[ math:cos(N1) | Stack ];
rpn("pow", [N1, N2 | Stack]) -> [math:pow(N2, N1) | Stack ];
rpn("sqrt", [N1 | _]) when (N1 < 0) -> throw({error, sqrt_negative_value});
rpn("sqrt", [N1 | Stack]) -> [math:sqrt(N1) | Stack];
rpn("neg", [N1 | Stack]) -> [-1*N1 | Stack];
rpn("d", [N1, N2 | Stack]) ->[math:sqrt(math:pow(N1,2) + math:pow(N2,2))| Stack];
rpn(X, Stack) -> [read(X)|Stack].

