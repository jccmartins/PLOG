:-use_module(library(clpfd)).
:-use_module(library(lists)).

:-consult('display.pl').
:-consult('data.pl').
:-consult('utils.pl').
:-consult('statistics.pl').

/* get or set cell value */
cellValue(_,0,_,_,_,0).
cellValue(_,_,0,_,_,0).
cellValue(_,Row,_,NRows,_,0) :- Row > NRows.
cellValue(_,_,Column,_,NColumns,0) :- Column > NColumns.
cellValue(Vars, Row, Column, _, NColumns, Value) :-
    N is (Row-1)*NColumns+Column,
    nth1(N, Vars, Value).

/* constrain initial info cells and their margins (if cell is different than 0 (water)) */
constrainInitialInfo(Vars, Row, Column, NRows, NColumns, ShipPiece) :-
    TopRow is Row-1,
    BottomRow is Row+1,
    LeftColumn is Column-1,
    RightColumn is Column+1,
    (ShipPiece == water ->
        cellValue(Vars, Row, Column, NRows, NColumns, 0);
    ShipPiece == circle ->
        cellValue(Vars, Row, Column, NRows, NColumns, 1),
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0);
    ShipPiece == square ->
        cellValue(Vars, Row, Column, NRows, NColumns, Value),
        Value #>= 2,
        cellValue(Vars, TopRow, Column, NRows, NColumns, Top),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, Left),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, Right),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, Bottom),
        (Top+1 #= Value #/\ Value+1 #= Bottom) #\/ (Left+1 #= Value #/\ Value+1 #= Right);
    ShipPiece == north ->
        cellValue(Vars, Row, Column, NRows, NColumns, 1),
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 2);
    ShipPiece == east ->
        cellValue(Vars, Row, Column, NRows, NColumns, Value),
        Value #>= 2,
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, Left),
        Left #= Value-1,
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),   
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0);
    ShipPiece == west ->
        cellValue(Vars, Row, Column, NRows, NColumns, 1),
        cellValue(Vars, TopRow, Column, NRows, NColumns, 0),      
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 2),
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0); 
    ShipPiece == south ->  
        cellValue(Vars, Row, Column, NRows, NColumns, Value),
        Value #>= 2,
        cellValue(Vars, TopRow, Column, NRows, NColumns, Top),
        Top #= Value-1,
        cellValue(Vars, Row, LeftColumn, NRows, NColumns, 0),    
        cellValue(Vars, Row, RightColumn, NRows, NColumns, 0),    
        cellValue(Vars, BottomRow, Column, NRows, NColumns, 0)).

/* fills board with initial info */
fillVarsWithInfo([],_,_,_).
fillVarsWithInfo([H|T], NRows, NColumns, Vars):-
    [[Row, Column], PieceType] = H,  
    constrainInitialInfo(Vars, Row, Column, NRows, NColumns, PieceType),
    fillVarsWithInfo(T, NRows, NColumns, Vars).

/* constrain number of ship pieces there are in each row or column */
constrain([], [], _).
constrain([H|T], [Constraint|ConstraintsTail], ShipsSize) :-
    length(H, ListLength),
    NumberOfZeros is ListLength-Constraint,
    pairWithEmpty(ShipsSize, ShipsSizePairs),
    append([0-NumberOfZeros], ShipsSizePairs, Cardinality),
    global_cardinality(H, Cardinality),
    constrain(T, ConstraintsTail, ShipsSize).

/* constrain ships to be non adjacent */
constrainDiagonals(_, Row, _, NRows, _) :-
    Row > NRows.

constrainDiagonals(Vars, Row, Column, NRows, NColumns) :-
    Column > NColumns,
    BottomRow is Row+1,
    constrainDiagonals(Vars, BottomRow, 1, NRows, NColumns).
    
constrainDiagonals(Vars, Row, Column, NRows, NColumns) :-
    N is (Row-1)*NColumns+Column,
    nth1(N, Vars, Value),
    TopRow is Row-1,
    BottomRow is Row+1,
    LeftColumn is Column-1,
    RightColumn is Column+1,
    cellValue(Vars, TopRow, LeftColumn, NRows, NColumns, TopLeft),
    cellValue(Vars, TopRow, RightColumn, NRows, NColumns, TopRight),
    cellValue(Vars, BottomRow, LeftColumn, NRows, NColumns, BottomLeft),
    cellValue(Vars, BottomRow, RightColumn, NRows, NColumns, BottomRight),
    Value*TopLeft #= 0,
    Value*TopRight #= 0,
    Value*BottomLeft #= 0,
    Value*BottomRight #= 0,
    constrainDiagonals(Vars, Row, RightColumn, NRows, NColumns).

/* get ships size */
getShipsSize([],[]).
getShipsSize([ShipPair|ShipsTail], ShipsSize) :-
    ShipSize-_ = ShipPair,
    getShipsSize(ShipsTail, AuxShipsSize),
    append([ShipSize], AuxShipsSize, ShipsSize).

/* get pieces of ships with a certain size */
getShipsPieces(0,_,[]).
getShipsPieces(Size, NumberOfShips, Pieces) :-
    length(SamePieces, NumberOfShips),
    maplist(=(Size), SamePieces),
    NewSize is Size-1,
    getShipsPieces(NewSize,NumberOfShips,AuxPieces),
    append(SamePieces,AuxPieces,Pieces).

/* get list with all pieces on the board */
getAllPieces([],[]).
getAllPieces([Ship|ShipsDataTail], AllPieces) :-
    Size-NumberOfShips = Ship,
    getShipsPieces(Size, NumberOfShips, Pieces),
    getAllPieces(ShipsDataTail, AuxAllPieces),
    append(Pieces, AuxAllPieces, AllPieces).

/* get list with pairs of ship piece and its total number on the board */
getAllPiecesCardinality(0,_,[]).
getAllPiecesCardinality(GreaterPiece, AllPieces, Cardinality) :-
    count(GreaterPiece,AllPieces,NumberOfPieces),
    NextGreaterPiece is GreaterPiece-1,
    getAllPiecesCardinality(NextGreaterPiece,AllPieces,AuxCardinality),
    append([GreaterPiece-NumberOfPieces],AuxCardinality,Cardinality).

/* constrain ship pieces with same size to be adjacent */ 
constrainShipsPieces(_, Row, _, NRows, _) :-
    Row > NRows.

constrainShipsPieces(Vars, Row, Column, NRows, NColumns) :-
    Column > NColumns,
    BottomRow is Row+1,
    constrainShipsPieces(Vars, BottomRow, 0, NRows, NColumns).
    
constrainShipsPieces(Vars, Row, Column, NRows, NColumns) :-
    cellValue(Vars, Row, Column, NRows, NColumns, Value),
    RightColumn is Column+1,
    cellValue(Vars, Row, RightColumn, NRows, NColumns, RightValue),
    TopRow is Row-1,
    cellValue(Vars, TopRow, RightColumn, NRows, NColumns, TopRightValue),
    (Value+1 #= RightValue #/\ TopRightValue #= 0) #\/ (TopRightValue+1 #= RightValue #/\ Value #= 0) #\/ RightValue #= 0,
    constrainShipsPieces(Vars, Row, RightColumn, NRows, NColumns).

/* solves a battleships puzzle with id ID (puzzles are on data.pl) */
battleships(ID, Vars):-
    data(ID, InitialInfo, PerRowData, PerColumnData, ShipsData),
    length(PerRowData, NRows),
    length(PerColumnData, NColumns),
    N is NRows*NColumns,
    length(Vars, N),
    
    % get all ships size to use to constrain number of ship Pieces in each row/column
    getShipsSize(ShipsData, ShipsSize),
    % get biggest ship size
    getMaxFromList(ShipsSize, _, MaxSize),
    domain(Vars,0,MaxSize),
    
    fillVarsWithInfo(InitialInfo, NRows, NColumns, Vars),

    list_to_matrix(Vars,NColumns,Board),

    % constrain rows and columns number of ship segments 
    constrain(Board, PerRowData, ShipsSize),
    transpose(Board, BoardTransposed, 0, NColumns),
    constrain(BoardTransposed, PerColumnData, ShipsSize),

    % constrain ships to be non-adjacent
    constrainDiagonals(Vars, 1, 1, NRows, NColumns),

    % get a list with all pieces on the board
    getAllPieces(ShipsData, AllPieces),
    getMaxFromList(AllPieces,_,GreaterPiece),
    getAllPiecesCardinality(GreaterPiece,AllPieces,PiecesCardinality),
    append([0-_],PiecesCardinality,Cardinality),
    % constrain ships size and number of Pieces on the board
    global_cardinality(Vars, Cardinality),

    % constrain ship pieces of the same ship to be adjacent incrementally
    % 1(size 1), 12(size 2), 123(size 3), 1234(size 4), ...
    constrainShipsPieces(Vars, 1, 0, NRows, NColumns),
    
    !,

    reset_timer,
    labeling([],Vars),
	print_time,
	fd_statistics,

    printBoard(Board, PerRowData, PerColumnData).



/* Generate random battleship puzzles */

/* constrain number of ship pieces there are in each row or column */
constrainRandom([], [], _).
constrainRandom([H|T], [Constraint|ConstraintsTail], ShipsSize) :-
    length(H, ListLength),
    NumberOfZeros #= ListLength-Constraint,
    pairWithEmpty(ShipsSize, ShipsSizePairs),
    append([0-NumberOfZeros], ShipsSizePairs, Cardinality),
    global_cardinality(H, Cardinality),
    constrainRandom(T, ConstraintsTail, ShipsSize).

/* constrain numbers so they are not adjacent on Rows and Columns data */
constrainThreeEqualNumbersTogether(RowColumnData, N) :-
    length(RowColumnData,Length),
    Aux is Length-1,
    N == Aux.

constrainThreeEqualNumbersTogether(RowColumnData, N) :-
    nth1(N,RowColumnData,Element),
    N1 is N+1,
    nth1(N1,RowColumnData,NextElement),
    N2 is N+2,
    nth1(N2,RowColumnData,NextNextElement),
    Element #\= NextElement #\/ Element #\= NextNextElement #\/ NextElement #\= NextNextElement,
    constrainThreeEqualNumbersTogether(RowColumnData,N1).

/* constrain rows and columns cardinality */
constrainRowsColumnsCardinality(-1,_,[]). 
constrainRowsColumnsCardinality(MaxConstraintNumber, MaxCardinality, RowsCardinality) :-
    Cardinality #=< MaxCardinality,
    NextConstraintNumber is MaxConstraintNumber-1,
    constrainRowsColumnsCardinality(NextConstraintNumber,MaxCardinality, AuxRowsCardinality),
    append([MaxConstraintNumber-Cardinality],AuxRowsCardinality,RowsCardinality).


/* get elements from board between rows InitialRow and FinalRow and columns InitialColumn and FinalColumn*/
getElementsBetweenColumns(_,_,Column,FinalColumn,[]) :- Column > FinalColumn.
getElementsBetweenColumns(Board,Row,Column,FinalColumn,Elements) :-
    nth1(Row,Board,RowElements),
    nth1(Column,RowElements,Element),
    NextColumn is Column+1,
    getElementsBetweenColumns(Board,Row,NextColumn,FinalColumn,AuxElements),
    append([Element],AuxElements,Elements).

getElementsBetween(_, Row, FinalRow,_,_,[]) :- Row > FinalRow.
getElementsBetween(Board, Row, FinalRow, Column, FinalColumn, Elements) :-
    getElementsBetweenColumns(Board,Row,Column,FinalColumn,RowElements),
    NextRow is Row+1,
    getElementsBetween(Board,NextRow,FinalRow,Column,FinalColumn,AuxElements),
    append(RowElements,AuxElements,Elements).

/* generates a random puzzle with NRows rows and NColumns columns
    ShipsData is a list with pairs of ship size and number of ships with that size
    example: [4-1,3-2,2-3,1-4], 1 ship with size 4, 2 ships with size 3 ...
*/
randomPuzzle(NRows, NColumns, Vars) :-
    shipsData(NRows,NColumns,ShipsData),
    length(PerRowData, NRows),
    length(PerColumnData, NColumns),
    MaxConstraintNumber is ceiling((NRows+1)/2),
    domain(PerRowData,0,MaxConstraintNumber),
    domain(PerColumnData,0,MaxConstraintNumber),
    append(PerRowData,PerColumnData,RowColumnData),
    N is NRows*NColumns,
    length(Vars, N),

    constrainThreeEqualNumbersTogether(RowColumnData,1),

    MaxCardinality is ceiling(NRows/5),
    constrainRowsColumnsCardinality(MaxConstraintNumber, MaxCardinality, RowsCardinality),
    constrainRowsColumnsCardinality(MaxConstraintNumber, MaxCardinality, ColumnsCardinality),
    global_cardinality(PerRowData,RowsCardinality),
    global_cardinality(PerColumnData,ColumnsCardinality),

    % get all ships size to use to constrain number of ship Pieces in each row/column
    getShipsSize(ShipsData, ShipsSize),
    % get biggest ship size
    getMaxFromList(ShipsSize, _, MaxSize),
    domain(Vars,0,MaxSize),
    
    list_to_matrix(Vars,NColumns,Board),

    % constrain rows and columns number of ship segments 
    constrainRandom(Board, PerRowData, ShipsSize),
    transpose(Board, BoardTransposed, 0, NColumns),
    constrainRandom(BoardTransposed, PerColumnData, ShipsSize),

    % constrain ships to be non-adjacent
    constrainDiagonals(Vars, 1, 1, NRows, NColumns),

    % get a list with all pieces on the board
    getAllPieces(ShipsData, AllPieces),

    length(AllPieces, TotalNumberOfPieces),

    getMaxFromList(AllPieces,_,GreaterPiece),
    getAllPiecesCardinality(GreaterPiece,AllPieces,PiecesCardinality),
    append([0-_],PiecesCardinality,Cardinality),
    % constrain ships size and number of Pieces on the board
    global_cardinality(Vars, Cardinality),


    /* constrain pieces on each quadrant so pieces are more spread */
    MiddleRows is floor(NRows/2),
    MiddleColumns is floor(NColumns/2),
    NextMiddleRows is MiddleRows+1,
    NextMiddleColumns is MiddleColumns+1,

    % get vars from quadrant 1, 2, 3 and 4
    getElementsBetween(Board, 1, MiddleRows, 1, MiddleColumns, Q1),
    getElementsBetween(Board, 1, MiddleRows, NextMiddleColumns, NColumns, Q2),
    getElementsBetween(Board, NextMiddleRows, NRows, 1, MiddleColumns, Q3),
    getElementsBetween(Board, NextMiddleRows, NRows, NextMiddleColumns, NColumns, Q4),

    MinPiecesPerQuadrant is ceiling(TotalNumberOfPieces/5),
    Max_Q1_zeros is MiddleRows*MiddleColumns-MinPiecesPerQuadrant,
    Max_Q2_zeros is (NColumns-MiddleColumns)*MiddleRows-MinPiecesPerQuadrant,
    Max_Q3_zeros is (NRows-MiddleRows)*MiddleColumns-MinPiecesPerQuadrant,
    Max_Q4_zeros is (NRows-MiddleRows)*(NColumns-MiddleColumns)-MinPiecesPerQuadrant,

    pairWithEmpty(ShipsSize, Q1_PiecesCardinality),
    Q1_zeros #=< Max_Q1_zeros,
    append([0-Q1_zeros],Q1_PiecesCardinality,Q1_Cardinality),
    % constrain ships size and number of Pieces on the board
    global_cardinality(Q1, Q1_Cardinality),

    pairWithEmpty(ShipsSize, Q2_PiecesCardinality),
    Q2_zeros #=< Max_Q2_zeros,
    append([0-Q2_zeros],Q2_PiecesCardinality,Q2_Cardinality),
    % constrain ships size and number of Pieces on the board
    global_cardinality(Q2, Q2_Cardinality),

    pairWithEmpty(ShipsSize, Q3_PiecesCardinality),
    Q3_zeros #=< Max_Q3_zeros,
    append([0-Q3_zeros],Q3_PiecesCardinality,Q3_Cardinality),
    % constrain ships size and number of Pieces on the board
    global_cardinality(Q3, Q3_Cardinality),

    pairWithEmpty(ShipsSize, Q4_PiecesCardinality),
    Q4_zeros #=< Max_Q4_zeros,
    append([0-Q4_zeros],Q4_PiecesCardinality,Q4_Cardinality),
    % constrain ships size and number of Pieces on the board
    global_cardinality(Q4, Q4_Cardinality),

    /* constrain ship pieces of the same ship to be adjacent incrementally
    1(size 1), 12(size 2), 123(size 3), 1234(size 4), ... */
    constrainShipsPieces(Vars, 1, 0, NRows, NColumns),
    
    !,

    reset_timer,
    labeling([bisect],Vars),
	print_time,
	fd_statistics,

    printBoard(Board, PerRowData, PerColumnData).
    