import 'package:game_2048/game_board/controller/state/game_board_state.dart';
import 'package:game_2048/game_board/model/movement_direction.dart';

class GameBoardEvent{

}

class GameBoardStartedEvent extends GameBoardEvent {

}

class GameBoardMovedEvent extends GameBoardEvent{
  final MovementDirection direction;
  final Duration duration;

  GameBoardMovedEvent(this.direction, [this.duration]);
}

class GameBoardResetEvent extends GameBoardEvent{

  final int x, y;

  GameBoardResetEvent([int x, int y]):
        this.x = x?.clamp(GameBoardState.minSize, GameBoardState.maxSize),
        this.y = y?.clamp(GameBoardState.minSize, GameBoardState.maxSize);
}

class GameBoardContinuedEvent extends GameBoardEvent{}