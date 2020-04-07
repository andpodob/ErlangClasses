%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Apr 2020 9:06 PM
%%%-------------------------------------------------------------------
-module(findMyParcelLocker).
-author("andrz").

-define(PEOPLE, [{random:uniform()*random:uniform(1000), random:uniform()*random:uniform(1000)} || _ <- lists:seq(1, 1)]).
-define(LOCKERS, [{random:uniform()*random:uniform(1000), random:uniform()*random:uniform(1000)} || _ <- lists:seq(1, 10)]).
%% API
-export([findMyParcelLocker/2, getLockersList/0, findForAllPeople/2,findForAllPeople/3, getPeopleList/0, findMyParcelLocker/3, findOnSubProcesses/2, findOnSubProcesses/3]).

distance({X1,Y1},{X2, Y2})->math:sqrt((X1-X2)*(X1-X2)+(Y1-Y2)*(Y1-Y2)).

getPeopleList()->?PEOPLE.
getLockersList()->?LOCKERS.

findMyParcelLocker(PersonLocation, [H|T])->lists:foldl(fun(LockerLocation,Acc)->
                                                            case distance(LockerLocation, PersonLocation) < distance(Acc, PersonLocation) of
                                                              true -> LockerLocation;
                                                              false -> Acc
                                                            end end,H, T).

%%findMyParcelLocker(PersonLocation, [H|T], multicore)->parent ! {PersonLocation, lists:foldl(fun(LockerLocation,Acc)->
%%  case distance(LockerLocation, PersonLocation) < distance(Acc, PersonLocation) of
%%    true -> LockerLocation;
%%    false -> Acc
%%  end end,H, T)}.

findForAllPeople(PeopleList, LockerList) -> [{Person,findMyParcelLocker(Person, LockerList)} || Person <- PeopleList].

findForAllPeople(PeopleList, LockerList, multicore) -> parent ! [{Person,findMyParcelLocker(Person, LockerList)} || Person <- PeopleList].

findMyParcelLocker(PersonLocation, LockerList, multiproc)->parent ! [{PersonLocation, findMyParcelLocker(PersonLocation, LockerList)}].

findOnSubProcesses(PeopleList, LockerList) ->
  case whereis(parent) of
    undefined -> register(parent, self());
    _->ok end,
  [spawn(?MODULE, findMyParcelLocker,[Person, LockerList, multiproc]) || Person <- PeopleList],
  collectResponses([], length(PeopleList)).

findOnSubProcesses(PeopleList, LockerList, N) ->
  case whereis(parent) of
    undefined -> register(parent, self());
    _->ok end,
  Len = ceil(length(PeopleList)/N),
  SubLists = [lists:sublist(PeopleList, X, Len) || X <- lists:seq(1,length(PeopleList),Len)],
  [spawn(?MODULE, findForAllPeople,[List, LockerList, multicore]) || List <- SubLists],
  collectResponses([], length(SubLists)).

collectResponses(L, Len) ->
  case Len == length(L) of true -> L ;
    false ->
      receive
        Res -> collectResponses(L++Res, Len)
      end
    end.