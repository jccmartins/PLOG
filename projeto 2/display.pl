symbol(0,S) :- S=' '. %water
symbol(1,S) :- S='$'. %ship

printSeparator(0) :- write('\n').
printSeparator(NColumns) :-
    write('---|'),
    N is NColumns-1,
    printSeparator(N).

printBoard(Board, PerRowData, PerColumnData) :-
    nl,
    length(PerColumnData, NColumns),
    printSeparator(NColumns),
    printMatrix(Board, 1, PerRowData, PerColumnData),
    !.

printMatrix([], Row, PerRowData, PerColumnData):-
    length(PerRowData, NRows),
    Row > NRows,
    printList(PerColumnData),
    write('\n').

printMatrix([Head|Tail], Row, [RowData|RowsDataTail], PerColumnData) :-
    NewRow is Row + 1,
    write(' '),
    printLine(Head, RowData),
    write('\n'),
    length(PerColumnData, NColumns),
    printSeparator(NColumns),
    printMatrix(Tail, NewRow, RowsDataTail, PerColumnData).

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
