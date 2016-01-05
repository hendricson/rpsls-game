-module(rpsls_util).

-export([index/2, mod/2]).

%% start: index function to find position of an item in a list
index(Item, List) -> index(Item, List, 1).

index(_, [], _)  -> not_found;
index(Item, [Item|_], Index) -> Index;
index(Item, [_|Tl], Index) -> index(Item, Tl, Index+1).
%% end.

%% start: calculate modulo
mod(0,_) -> 0;
mod(X,Y) when X > 0 -> X rem Y;
mod(X,Y) when X < 0 -> Y + X rem Y.
%% end.
