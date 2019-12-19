initialBoard([
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,water,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[water,empty,empty,empty,ship,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[empty,empty,empty,empty,empty,empty,empty,empty,empty,empty],
[empty,empty,empty,emptyConfirmed,empty,empty,empty,empty,empty,empty]
]).

symbol(empty,S) :- S=' '.
symbol(emptyConfirmed, S) :- S='x'.
symbol(ship,S) :- S='$'.
symbol(water,S) :- S='#'.

printBoard(Board) :-
    nl,
    write('---|---|---|---|---|---|---|---|---|---|\n'),
    rowsNumberOfShipSegments(RowsList),
    printMatrix(Board, 1, RowsList).

printMatrix([], 11, _):- 
    columnsNumberOfShipSegments(ColumnsList),
    printList(ColumnsList).

printMatrix([Head|Tail], N, [H|T]) :-
    N1 is N + 1,
    write(' '),
    printLine(Head, H),
    write('\n---|---|---|---|---|---|---|---|---|---|\n'),
    printMatrix(Tail, N1, T).

printLine([], H) :-
    format('~w', [H]).

printLine([Head|Tail], H) :-
    symbol(Head, S),
    write(S),
    write(' | '),
    printLine(Tail, H).

printList([]).
printList([H|T]) :-
    format(' ~w  ', [H]),
    printList(T).
