/* converts matrix to list */
matrixToList([],[]).
matrixToList([H|T], List):-
    matrixToList(T, AuxList),
    append(H, AuxList, List).

/* converts list to matrix */
list_to_matrix([], _, []).
list_to_matrix(List, Size, [Row|Matrix]):-
  list_to_matrix_row(List, Size, Row, Tail),
  list_to_matrix(Tail, Size, Matrix).

list_to_matrix_row(Tail, 0, [], Tail).
list_to_matrix_row([Item|List], Size, [Item|Row], Tail):-
  NSize is Size-1,
  list_to_matrix_row(List, NSize, Row, Tail).

/* transpose a matrix */
transposeList([],[],_,_).
transposeList([H|T], List, N, Size) :-
    transposeList(T, AuxList, N, Size),
    nth1(N, H, Elem),
    append([Elem], AuxList, List).

transpose(_,[], Size, Size).
transpose(Matrix, MatrixTransposed, N, Size) :-
    N1 is N+1,
    transpose(Matrix, AuxMatrixTransposed, N1, Size),
    transposeList(Matrix, List, N1, Size),
    append([List], AuxMatrixTransposed, MatrixTransposed).

/*get Value from Board*/
getValueFromList([H|_T], 1, Value) :-
        Value = H.

getValueFromList([_H|T], Index, Value) :-
        Index #> 1,
        Index1 #= Index - 1,
        getValueFromList(T, Index1, Value).

getValueFromMatrix(_,0,_,0).
getValueFromMatrix(_,_,0,0).
getValueFromMatrix(_,11,_,0).
getValueFromMatrix(_,_,11,0).

getValueFromMatrix([H|_T], 1, Column, Value) :-
        getValueFromList(H, Column, Value).

getValueFromMatrix([_H|T], Line, Column, Value) :-
        Line #> 1,
        Line1 #= Line - 1,
        getValueFromMatrix(T, Line1, Column, Value).
