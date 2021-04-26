import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../model/movement_direction.dart';
import '../model/tile.dart';

class GameController extends ChangeNotifier{

  static const int
  minSize = 3,
      maxSize = 20,
      _initTiles = 2;

  int _x, _y;
  final Random _random = Random();

  List<List<List<Tile>>> _board;
  List<List<List<Tile>>> _uiBoard;

  int _score, _bestScore;

  Timer mergeTimer;

  GameController(int x, int y){
    initGame(x: x, y: y);
  }

  List<List<List<Tile>>> get emptyTiles => _board
      .map((e) => e.where((e) => e.isEmpty).toList())
      .where((e) => e.isNotEmpty).toList();


  List<List<List<Tile>>> get board => _uiBoard;
  int get score => _score;
  int get bestScore => _bestScore;
  int get rows => _x;
  int get columns => _y;

  void initGame({int x, int y, int bestScore = 0}){
    if(x != null)
      _x = x.clamp(minSize, maxSize);
    if(y != null)
      _y = y.clamp(minSize, maxSize);
    _board = List.generate(_x, (index) => List.generate(_y, (index) => []));
    _uiBoard = _board;
    _score = 0;
    _bestScore = bestScore ?? 0;
    for(int i = 0; i < _initTiles; i++)
      _addRandomTile();
    // _board[0][0].add(Tile(2));
    // _board[0][1].add(Tile(4));
    // _board[0][2].add(Tile(2));
    // _board[0][3].add(Tile(4));
    //
    //
    // _board[1][0].add(Tile(4));
    // _board[1][1].add(Tile(2));
    // _board[1][2].add(Tile(4));
    // _board[1][3].add(Tile(2));
    //
    //
    // _board[2][0].add(Tile(2));
    // _board[2][1].add(Tile(4));
    // _board[2][2].add(Tile(2));
    // _board[2][3].add(Tile(4));
    //
    //
    // _board[3][0].add(Tile(4));
    // _board[3][1].add(Tile(2));
    // _board[3][2].add(Tile(4));
    // _board[3][3].add(Tile(2));
    notifyListeners();
  }

  void _addRandomTile(){
    var emptyTiles = this.emptyTiles;
    if(emptyTiles.isEmpty)
      return;
    int tileValue = _random.nextBool() ? 2 : 4;
    ((emptyTiles..shuffle(_random)).first..shuffle()).first.add(Tile(tileValue));
    // _printBoard();
  }

  void move(MovementDirection direction, [Duration duration]) async {
    var offsets = _getOffsets(direction);
    var iterables = _getLoopIterables(direction);
    var changes = _calculateMovements(iterables, offsets);
    var merges = _calculateMerges(iterables, offsets);
    if(changes == 0 && merges == 0)
      return;
    _calculateMovements(iterables, offsets);
    _uiBoard = _board.map((e) => e.map((e) => e.map((e) => e).toList()).toList()).toList();
    notifyListeners();
    _merge();
    _addRandomTile();
    mergeTimer?.cancel();
    mergeTimer = Timer(duration ?? Duration(), (){
      _uiBoard = _board.map((e) => e.map((e) => e.map((e) => e).toList()).toList()).toList();
      notifyListeners();
    });
  }



  void _printBoard(){
    print(_board.join("\n"));
    print('');
  }

  List<int> _getOffsets(MovementDirection direction){
    return [
      (direction == MovementDirection.up ? -1 : direction == MovementDirection.down ? 1 : 0),
      (direction == MovementDirection.left ? -1 : direction == MovementDirection.right ? 1 : 0),
    ];
  }

  List<Iterable<int>> _getLoopIterables(MovementDirection direction){
    var x = List.generate(_x, (index) => index);
    var y = List.generate(_y, (index) => index);
    return [
      (direction == MovementDirection.up ? x: x.reversed),
      (direction == MovementDirection.left ? y: y.reversed),
    ];
  }

  int _calculateMovements(List<Iterable<int>> iterables, List<int> offsets){

    var localChanges = 0, totalChanges = 0;
    do{
      localChanges = 0;
      for(int i in iterables[0]){
        for(int j in iterables[1]){
          var xTarget = i + offsets[0];
          var yTarget = j + offsets[1];
          if(xTarget != xTarget.clamp(0, _x-1) || yTarget != yTarget.clamp(0, _y-1))
            continue;
          if(_board[i][j].isEmpty)
            continue;
          if(_board[xTarget][yTarget].isEmpty){
            // print('$i $j $xTarget $yTarget');
            _board[xTarget][yTarget] = _board[i][j];
            _board[i][j] = [];
            localChanges += 1;
          }
        }
        totalChanges += localChanges;
      }
    } while(localChanges > 0);
    return totalChanges;
  }

  int _calculateMerges(List<Iterable<int>> iterables, List<int> offsets){
    var merges = 0;
    for(int i in iterables[0]){
      for(int j in iterables[1]){
        var xTarget = i + offsets[0];
        var yTarget = j + offsets[1];
        if(xTarget != xTarget.clamp(0, _x-1) || yTarget != yTarget.clamp(0, _y-1))
          continue;
        if(_board[i][j].isEmpty)
          continue;
        if(_board[xTarget][yTarget].length == 1 &&
            _board[i][j].length == 1 &&
            _board[xTarget][yTarget][0].value == _board[i][j][0].value){
          _board[xTarget][yTarget].addAll(_board[i][j]);
          _board[i][j] = [];
          merges++;
        }
      }
    }
    return merges;
  }

  void _merge(){
    for(var row in _board)
      for(var col in row)
        if(col.length > 1){
          var mergedValue = col.reduce(
                  (v, e) =>
                  Tile(v.value + e.value, parents: Set<Tile>.of([]..add(e)..add(v)))
          );
          // print("Merge ${mergedValue.parents}");
          col.clear();
          col.add(mergedValue);
          _score += mergedValue.value;
          if(_score > _bestScore)
            _bestScore = _score;
        }
  }

  int calculateAvailableMoves(){
    var localChanges = 0, totalChanges = 0;
    for(var direction in MovementDirection.values){
      final iterables = _getLoopIterables(direction);
      final offsets = _getOffsets(direction);
      localChanges = 0;
      for(int i in iterables[0]){
        for(int j in iterables[1]){
          var xTarget = i + offsets[0];
          var yTarget = j + offsets[1];
          if(xTarget != xTarget.clamp(0, _x-1) || yTarget != yTarget.clamp(0, _y-1))
            continue;
          if(_board[i][j].isEmpty)
            continue;
          if(_board[xTarget][yTarget].isEmpty ||
              (_board[xTarget][yTarget].length == 1 &&
              _board[i][j].length == 1 &&
              _board[xTarget][yTarget][0].value == _board[i][j][0].value
              )){
            localChanges += 1;
          }
        }
        totalChanges += localChanges;
      }
    }

    return totalChanges;
  }

}
