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

/* generates a random puzzle with NRows rows and NColumns columns
    ShipsData is a list with pairs of ship size and number of ships with that size
    example: [4-1,3-2,2-3,1-4], 1 ship with size 4, 2 ships with size 3 ...
*/
randomPuzzle(NRows, NColumns, ShipsData, Vars) :-
    length(PerRowData, NRows),
    length(PerColumnData, NColumns),
    domain(PerRowData,0,NRows),
    domain(PerColumnData,0,NColumns),
    N is NRows*NColumns,
    length(Vars, N),
    
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
    