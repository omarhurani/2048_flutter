import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:game_2048/game_board/controller/event/game_board_event.dart';
import 'package:game_2048/game_board/controller/state/game_board_state.dart';
import 'package:game_2048/game_board/model/movement_direction.dart';
import 'package:game_2048/game_board/model/tile.dart';
import 'package:game_2048/game_board/repo/saved_game_board_repo.dart';

class GameBoardBloc extends Bloc<GameBoardEvent, GameBoardState>{

  static const int _initTiles = 2;

  final SavedGameBoardRepository _savedGameBoardRepository;
  Timer _mergeTimer;

  GameBoardBloc(this._savedGameBoardRepository):
        super(null);

  @override
  Stream<GameBoardState> mapEventToState(GameBoardEvent event) async *{
    switch(event.runtimeType){
      case GameBoardStartedEvent:
        yield await _startGame();
        break;
      case GameBoardMovedEvent:{
        var movementEvent = (event as GameBoardMovedEvent);
        var newState = _moveBoard(movementEvent.direction, movementEvent.duration);
        if(newState != null)
          yield * newState;
      }

        break;
      case GameBoardResetEvent:
        yield await _resetBoard((event as GameBoardResetEvent).x, (event as GameBoardResetEvent).y);
        break;
    }
  }

  Future<GameBoardState> _startGame() async {
    return await _savedGameBoardRepository.loadGameBoardState() ??
    GameBoardState().copyWithRandomTiles(_initTiles);

  }

  Future<GameBoardState> _resetBoard(int x, int y) async {
    var gameBoard = await _savedGameBoardRepository.loadGameBoardState(
      x ?? state.x,
      y ?? state.y
    );
    var bestScore = gameBoard.bestScore ?? 0;
    return GameBoardState(
      x: x,
      y: y,
      bestScore: bestScore,
      score: 0
    ).copyWithRandomTiles(_initTiles);
  }

  Stream<GameBoardState> _moveBoard(MovementDirection direction, [Duration duration]) async *{
    var offsets = _getOffsets(direction);
    var iterables = _getLoopIterables(direction);
    var newState = state.copy();
    var changes = _calculateBoardMovements(newState, iterables, offsets);
    var merges = _calculateBoardMerges(newState, iterables, offsets);
    if(changes == 0 && merges == 0)
      return;
    _calculateBoardMovements(newState, iterables, offsets);
    yield newState;
    var mergedState = _mergeBoard(newState);
    mergedState = mergedState.copyWithRandomTiles();
    _mergeTimer?.cancel();
    await Future.delayed(duration ?? Duration());
    if(newState == state){
      yield mergedState;
    }
  }

  List<int> _getOffsets(MovementDirection direction){
    return [
      (direction == MovementDirection.up ? -1 : direction == MovementDirection.down ? 1 : 0),
      (direction == MovementDirection.left ? -1 : direction == MovementDirection.right ? 1 : 0),
    ];
  }

  List<Iterable<int>> _getLoopIterables(MovementDirection direction){
    var x = List.generate(state.x, (index) => index);
    var y = List.generate(state.y, (index) => index);
    return [
      (direction == MovementDirection.up ? x: x.reversed),
      (direction == MovementDirection.left ? y: y.reversed),
    ];
  }

  int _calculateBoardMovements(GameBoardState state, List<Iterable<int>> iterables, List<int> offsets){

    var localChanges = 0, totalChanges = 0;
    do{
      localChanges = 0;
      for(int i in iterables[0]){
        for(int j in iterables[1]){
          var xTarget = i + offsets[0];
          var yTarget = j + offsets[1];
          if(xTarget != xTarget.clamp(0, state.x-1) || yTarget != yTarget.clamp(0, state.y-1))
            continue;
          if(state.board[i][j].isEmpty)
            continue;
          if(state.board[xTarget][yTarget].isEmpty){
            // print('$i $j $xTarget $yTarget');
            state.board[xTarget][yTarget].addAll(state.board[i][j]);
            state.board[i][j].clear();
            localChanges += 1;
          }
        }
        totalChanges += localChanges;
      }
    } while(localChanges > 0);
    return totalChanges;
  }

  int _calculateBoardMerges(GameBoardState state, List<Iterable<int>> iterables, List<int> offsets){
    var merges = 0;
    for(int i in iterables[0]){
      for(int j in iterables[1]){
        var xTarget = i + offsets[0];
        var yTarget = j + offsets[1];
        if(xTarget != xTarget.clamp(0, state.x-1) || yTarget != yTarget.clamp(0, state.y-1))
          continue;
        if(state.board[i][j].isEmpty)
          continue;
        if(state.board[xTarget][yTarget].length == 1 &&
            state.board[i][j].length == 1 &&
            state.board[xTarget][yTarget][0].value == state.board[i][j][0].value){
          state.board[xTarget][yTarget].addAll(state.board[i][j]);
          state.board[i][j].clear();
          merges++;
        }
      }
    }
    return merges;
  }

  GameBoardState _mergeBoard(GameBoardState state){
    state = state.copy();
    var score = state.score;
    var bestScore = state.bestScore;
    for(var row in state.board)
      for(var col in row)
        if(col.length > 1){
          var mergedValue = col.reduce(
                  (v, e) =>
                  Tile(v.value + e.value, parents: Set<Tile>.of([]..add(e)..add(v)))
          );
          // print("Merge ${mergedValue.parents}");
          col.clear();
          col.add(mergedValue);
          score += mergedValue.value;
          if(score > bestScore)
            bestScore = score;
        }
    return state.copyWith(
      score: score,
      bestScore: bestScore,
    );
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
          if(xTarget != xTarget.clamp(0, state.x-1) || yTarget != yTarget.clamp(0, state.y-1))
            continue;
          if(state.board[i][j].isEmpty)
            continue;
          if(state.board[xTarget][yTarget].isEmpty ||
              (state.board[xTarget][yTarget].length == 1 &&
                  state.board[i][j].length == 1 &&
                  state.board[xTarget][yTarget][0].value == state.board[i][j][0].value
              )){
            localChanges += 1;
          }
        }
        totalChanges += localChanges;
      }
    }

    return totalChanges;
  }

  @override
  void onChange(Change<GameBoardState> change) {
    super.onChange(change);
    _savedGameBoardRepository.saveGameBoardState(change.nextState);
  }

}

