%%%-------------------------------------------------------------------
%%% @author andrz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Apr 2020 11:07 PM
%%%-------------------------------------------------------------------
-module(pollution).
-author("andrz").


%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getStationMean/3, getOneValue/4, getDailyMean/3, getStationMedian/3, getDailyMax/3]).

-type cords(_X,_Y) :: tuple().

-type station(_Name, _Cords) :: tuple().

-import(lists, [nth/2, sort/1]).

-type measure(_Datetime, _Type, _Val) :: tuple().

-record(cords, {
  x :: float(),
  y :: float()
}).

-record(station, {
  name :: unicode:chardata(),
  cords :: cords(_,_)
}).
-record(measure, {
  datetime :: calendar:datetime(),
  type :: unicode:chardata(),
  val
}).
-record(monitor, {
  list :: lists:list(),
  dict :: dict:dict(station(_,_), measure(_,_,_))
}).

%tworzy monitor
createMonitor() -> #monitor{list = [], dict = dict:new()}.


%dodaje stacje do monitora
addStation(Name, Cords, Monitor) ->
  case lists:member(#station{name = Name, cords = Cords}, Monitor#monitor.list)
  of true -> {error, "Proba dodania drugi raz tej samej stacji"};
     false-> #monitor{list = Monitor#monitor.list++[#station{name = Name, cords = Cords}], dict = Monitor#monitor.dict}
  end.

%zwraca daną stację z okreslonej nazwy lub wspolzednych
getStation(Station, Monitor)->lists:filter(fun(#station{name = N,cords = C})-> (C == Station) or (N == Station) end, Monitor#monitor.list).

%obudowuje funkcje getOneVal aby rozwiazac problem przekazywania stacji jako Nazwe lub Wspolzedne
getOneValue(NameOrCords, Date, Type, Monitor)->
  getOneVal(getStation(NameOrCords,Monitor), Date, Type, Monitor).

%pobiera jedna wartosc okreslonego typu, danego dnia z danej stacji
getOneVal([],_,_,_)->{error, "Nie ma takiej stacji"};
getOneVal([Station|_], Date, Type, Monitor)->
  case dict:is_key(Station, Monitor#monitor.dict)
    of true ->
      case lists:filter(fun(#measure{datetime = D, type = T, val=_})->(T == Type) and (D == Date) end, dict:fetch(Station, Monitor#monitor.dict))
        of [] -> {error, "Nie ma takiego pomiaru na tej stacji"};
        [H|_]-> H
        end;
      false ->{error, "Nie zarejestrowano pomiarow na tej stacji"}
  end.

%pobiera wszystkie wartosci z danej stacji danego typu
getValues([],_,_)->{error, "Nie ma takiej stacji"};
getValues([Station|_], Type, Monitor)->
  case dict:is_key(Station, Monitor#monitor.dict)
  of true -> lists:filter(fun(#measure{datetime = D, type = T, val=_})->(T == Type) end, dict:fetch(Station, Monitor#monitor.dict));
     false ->{error, "Nie zarejestrowano pomiarow na tej stacji"}
  end.

%funckja obudowuje addVal(funkcja implementujaca faktyczne dodawanie), obudowanie extraktuje stacje z podanej nazwy
%lub wspolzednych
addValue(NameOrCords, Time, Type, Val, Monitor)->
  addVal(getStation(NameOrCords, Monitor), Monitor, Time, Type, Val).

%sprawdza czy stacja istnieje, jezeli tak, to dodaje pomiar do listy pomiarow tej stacji
addVal([],_,_,_,_)->{error, "Nie ma takiej stacji"};
addVal([Station|_], Monitor, Time, Type, Val)->
  case dict:is_key(Station, Monitor#monitor.dict)
  of true ->
    case lists:filter(fun(#measure{datetime = D, type = T, val=_})->(T == Type) and (D == Time) end, dict:fetch(Station, Monitor#monitor.dict))
      of [] -> #monitor{list= Monitor#monitor.list,dict = dict:append(Station,#measure{datetime = Time, type=Type, val=Val},Monitor#monitor.dict)};
      _ -> {error, "Taki pomair juz zostal wprowadzony"}
    end;
  false ->#monitor{list= Monitor#monitor.list,dict = dict:append(Station,#measure{datetime = Time, type=Type, val=Val},Monitor#monitor.dict)}
  end.

%funckja obudowuje removeVal(funkcja implementujaca faktyczne usuwanie), obudowanie extraktuje stacje z podanej nazwy
%lub wspolzednych
removeValue(NameOrCords, Monitor, Time, Type)->
  removeVal(getStation(NameOrCords, Monitor), Monitor, Time,Type).

%funckja sprawdza czy w strukturze znajduje sie okreslony pomiar a nastepnie jeżeli tak jest to jest on usuwany
removeVal([], _, _, _)->{error, "Nie ma takiej stacji"};
removeVal([Station|_], Monitor, Time, Type)->
  case dict:is_key(Station, Monitor#monitor.dict)
  of true ->
    #monitor{list = Monitor#monitor.list, dict = dict:update(Station, fun(Old)->lists:filter(fun(#measure{datetime = D, type = T, val = _})->(D=/=Time) or (T=/=Type)end, Old) end, Monitor#monitor.dict)};
    false ->{error, "Nie ma takiego pomiaru"}
  end.

%pierwsza linijka pobiera wszystkie pomiary danego typu z danej stacji, nastepnie przy pomocy foldl obliczana jest srednia
getStationMean(NameOrCords, Type, Monitor)->
  L = getValues(getStation(NameOrCords, Monitor), Type, Monitor),
  Len = length(L),
  lists:foldl(fun(#measure{datetime = _, type = _, val = X}, Acc)->Acc + X/Len end, 0, L).

%przyjmuje typ, dzien oraz monitor, zwraca srednia z pomiarow danego typu ze wszystkich stacji,
%pierwsza linijka pobiera pomiary ze wszystkich stacji podlaczonych do monitora, danego typu z danego dnia
%druga linijka oblicza srednia
getDailyMean(Type, Day, Monitor)->
  V = lists:foldl(fun(Station, Acc)->Acc++lists:filter(fun(#measure{datetime = {D,_}, type = _, val=_}) -> D == Day end, getValues([Station], Type, Monitor)) end, [], Monitor#monitor.list),
  L = length(V),
  lists:foldl(fun(#measure{datetime = _, type = _, val = X}, Acc)->Acc + X/L end, 0, V).

%przyjmuje nazwe lub wspolzedne stacji, typ pomiaru oraz monitor, zwraca mediane z pomiarow danego typu z danej stacji
getStationMedian(NameOrCords,Type, Monitor)->
  L = getValues(getStation(NameOrCords, Monitor), Type, Monitor),
  median(lists:map(fun (#measure{datetime = _,type = _,val = V})->V  end,L)).

%przyjmuje typ, dzien(date bez godziny) oraz monitor, zwraca dzienne maksimum(ze wszystkich stacji)
getDailyMax(Type, Day, Monitor)->
  V = lists:foldl(fun(Station, Acc)->Acc++lists:filter(fun(#measure{datetime = {D,_}, type = _, val=_}) -> D == Day end, getValues([Station], Type, Monitor)) end, [], Monitor#monitor.list),
  lists:foldl(fun(#measure{datetime = _, type = _, val = Val}, Acc)->case (Val > Acc) of true -> Val; false -> Acc end end, 0, V).



%funckja zwraca mediane z nieposortowanej listy wartosci
median(Unsorted) ->
  Sorted = sort(Unsorted),
  Length = length(Sorted),
  Mid = Length div 2,
  Rem = Length rem 2,
  (nth(Mid+Rem, Sorted) + nth(Mid+1, Sorted)) / 2.

