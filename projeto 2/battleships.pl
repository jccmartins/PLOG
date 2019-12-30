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

/* get total number of a certain piece (piece is the Size of the ship) on the board */
getNumberOfPieces(_,[],0).
getNumberOfPieces(Piece, [Ship|ShipsDataTail], NumberOfPieces) :-
    Size-NumberOfShips = Ship,
    (Size >= Piece ->
        Aux is NumberOfShips;
    Aux = 0),
    getNumberOfPieces(Piece, ShipsDataTail, AuxNumberOfPieces),
    NumberOfPieces is Aux+AuxNumberOfPieces.

/* get list with pairs ShipSize-TotalPiecesOnTheBoard */
getPairShipsSizeAndPieces(ShipsData,ShipIndex,[]) :-
    length(ShipsData, Length),
    ShipIndex > Length.

getPairShipsSizeAndPieces(ShipsData, ShipIndex, SizePiecesPairs) :-
    nth1(ShipIndex, ShipsData, Ship),
    Size-_ = Ship,
    getNumberOfPieces(Size, ShipsData, NumberOfPieces),
    NewShipIndex is ShipIndex+1,
    getPairShipsSizeAndPieces(ShipsData, NewShipIndex, AuxSizePiecesPairs),
    append([Size-NumberOfPieces], AuxSizePiecesPairs, SizePiecesPairs).

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

/* battleships */
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

    % get a list with pairs ship size and number of ship Pieces of that size on the board
    getPairShipsSizeAndPieces(ShipsData, 1, SizePiecesPairs),
    append([0-_], SizePiecesPairs, Cardinality),
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
    