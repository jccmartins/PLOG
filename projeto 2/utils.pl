/* count occurrences of a element Symbol in a list */
count(_,[],0).
count(Symbol,[H|T],N) :- H == Symbol, count(Symbol, T, N1), N is N1 + 1.
count(Symbol, [H|T],N) :- H \== Symbol, count(Symbol, T, N).


/*replace [Line, Column] position on the board*/
replaceInList([_H|T], 1, Value, [Value|T]).

replaceInList([H|T], Index, Value, [H|TNew]) :-
        Index > 1,
        Index1 is Index - 1,
        replaceInList(T, Index1, Value, TNew).

replaceInMatrix([H|T], 1, Column, Value, [HNew|T]) :-
        replaceInList(H, Column, Value, HNew).

replaceInMatrix([H|T], Line, Column, Value, [H|TNew]) :-
        Line > 1,
        Line1 is Line - 1,
        replaceInMatrix(T, Line1, Column, Value, TNew).

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

/* getVars([
        [1,2,3,4,5,6,7,8,9,10],
        [11,12,13,14,15,16,17,18,19,20],
        [21,22,23,24,25,26,27,28,29,30],
        [31,32,33,34,35,36,37,38,39,40],
        [41,42,43,44,45,46,47,48,49,50],
        [51,52,53,54,55,56,57,58,59,60],
        [61,62,63,64,65,66,67,68,69,70],
        [71,72,73,74,75,76,77,78,79,80],
        [81,82,83,84,85,86,87,88,89,90],
        [91,92,93,94,95,96,97,98,99,100]
        ],Vars), write(Vars).
*/

