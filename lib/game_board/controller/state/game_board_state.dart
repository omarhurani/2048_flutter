import 'dart:math';

import 'package:game_2048/game_board/model/tile.dart';
import 'package:game_2048/utils/extensions.dart';

class GameBoardState{

  static const int minSize = 3, maxSize = 20;

  final Random _random;

  List<List<List<Tile>>> _board;
  int _x, _y;
  int _score, _bestScore;

  List<List<List<Tile>>> get emptyTiles => _board
      .map((e) => e.where((e) => e.isEmpty).toList())
      .where((e) => e.isNotEmpty).toList();

  GameBoardState({
    int x = 4, int y = 4,
    List<List<List<Tile>>> board,
    int score,
    int bestScore
  }) : this._x = x,
        this._y = y,
        this._board = board,
        this._score = score,
        this._bestScore = bestScore,
        this._random = Random()
  {
    _board = _board ?? List<List<List<Tile>>>.generate(
        x, (index) => List<List<Tile>>.generate(
        y, (index) => <Tile>[])) ;
    score = score ?? 0;
    bestScore = bestScore ?? 0;
  }

  GameBoardState copy(){
    return this.copyWith();
  }

  GameBoardState copyWith({
    int x, int y,
    List<List<List<Tile>>> board,
    int score,
    int bestScore
  }){

    return GameBoardState(
      x: x ?? _x,
      y: y ?? _y,
      bestScore: bestScore ?? _bestScore,
      score: score ?? _score,
      board: (board ?? _board).map<List<List<Tile>>>(
        (e) => e.map<List<Tile>>(
          (e) => e.map<Tile>(
            (e) => e).toList()
        ).toList()
      ).toList(),
    );
  }

  GameBoardState copyWithRandomTiles([int randomTileCount = 1]){
    var count = randomTileCount ?? 1;
    var state = this.copy();
    // var emptyTiles = state.emptyTiles;
    while(count-- != 0){
      if(state.emptyTiles.isNotEmpty){
        int tileValue = _random.nextBool() ? 2 : 4;
        ((state.emptyTiles..shuffle(_random)).first..shuffle()).first.add(Tile(tileValue));
      }
    }
    return state;
  }

  factory GameBoardState.fromJson(Map<String, dynamic> json){
    return GameBoardState(
      x: json['x'],
      y: json['y'],
      board: json['board']
          .map<List<List<Tile>>>((e) => // rows
            e.map<List<Tile>>((e) => // entry per row
              e.map<Tile>((e) => // tile per entry
                Tile.fromJson(e) // tile to JSON
              ).toList() as List<Tile>
            ).toList() as List<List<Tile>>
          ).toList() as List<List<List<Tile>>>,
      score: json['score'],
      bestScore: json['bestScore']
    );
  }

  Map<String, dynamic> toJson() => {
    'score': _score,
    'bestScore': _bestScore,
    'x': _x,
    'y': _y,
    'board': _board
      .map((e) => // rows
        e.map((e) => // entry per row
          e.map((e) => // tile per entry
            e.toJson() // tile to JSON
        ).toList()
      ).toList()
    ).toList()
  };

  List<List<List<Tile>>> get board => _board;
  int get x => _x;
  int get y => _y;
  int get score => _score ?? 0;
  int get bestScore => _bestScore ?? 0;

  int get maxTileValue{
    int maxTileValue = 0;
    for(var row in board)
      for(var cell in row)
        for(var tile in cell)
          if(tile != null && (tile.value ?? 0) > maxTileValue)
            maxTileValue = tile.value;

    return maxTileValue;
  }

}