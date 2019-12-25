initialBoard([
[_A1,_A2,_A3,_A4,_A5,_A6,_A7,_A8,_A9,_A10],
[_A11,_A12,_A13,_A14,_A15,_A16,_A17,_A18,_A19,_A20],
[_A21,_A22,_A23,_A24,_A25,_A26,_A27,_A28,_A29,_A30],
[_A31,_A32,_A33,_A34,_A35,_A36,_A37,_A38,_A39,_A40],
[_A41,_A42,_A43,_A44,_A45,_A46,_A47,_A48,_A49,_A50],
[_A51,_A52,_A53,_A54,_A55,_A56,_A57,_A58,_A59,_A60],
[_A61,_A62,_A63,_A64,_A65,_A66,_A67,_A68,_A69,_A70],
[_A71,_A72,_A73,_A74,_A75,_A76,_A77,_A78,_A79,_A80],
[_A81,_A82,_A83,_A84,_A85,_A86,_A87,_A88,_A89,_A90],
[_A91,_A92,_A93,_A94,_A95,_A96,_A97,_A98,_A99,_A100]
]).

symbol(0,S) :- S=' '. %water
symbol(1,S) :- S='$'. %ship

printBoard(Board) :-
    nl,
    write('---|---|---|---|---|---|---|---|---|---|\n'),
    data(_,PerRowData, _),
    printMatrix(Board, 1, PerRowData).

printMatrix([], 11, _):- 
    data(_,_,PerColumnData),
    printList(PerColumnData),
    write('\n').

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
