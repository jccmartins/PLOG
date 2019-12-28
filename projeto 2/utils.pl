/* converts list to matrix, size is the number of columns we want for the matrix */
list_to_matrix([], _, []).
list_to_matrix(List, Size, [Row|Matrix]):-
  list_to_matrix_row(List, Size, Row, Tail),
  list_to_matrix(Tail, Size, Matrix).

list_to_matrix_row(Tail, 0, [], Tail).
list_to_matrix_row([Item|List], Size, [Item|Row], Tail):-
  NSize is Size-1,
  list_to_matrix_row(List, NSize, Row, Tail).

/* transpose a matrix */
transposeList([],[],_).
transposeList([H|T], List, N) :-
    transposeList(T, AuxList, N),
    nth1(N, H, Elem),
    append([Elem], AuxList, List).

transpose(_,[], NColumns, NColumns).
transpose(Matrix, MatrixTransposed, N, NColumns) :-
    N1 is N+1,
    transpose(Matrix, AuxMatrixTransposed, N1, NColumns),
    transposeList(Matrix, List, N1),
    append([List], AuxMatrixTransposed, MatrixTransposed).
