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

  static const int minSize = 3, maxSize = 20;

  final int x, y;

  GameBoardResetEvent([int x, int y]):
        this.x = x?.clamp(minSize, maxSize),
        this.y = y?.clamp(minSize, maxSize);
}