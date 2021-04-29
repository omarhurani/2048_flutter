
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_2048/game_board/controller/bloc/game_board_bloc.dart';
import 'package:game_2048/game_board/controller/event/game_board_event.dart';
import 'package:game_2048/game_board/controller/state/game_board_state.dart';
import 'package:game_2048/game_board/model/movement_direction.dart';
import 'package:game_2048/game_board/model/tile.dart';
import 'package:game_2048/utils/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBoardBody extends StatefulWidget {

  const GameBoardBody({
    Key key,
  }) : super(key: key);


  @override
  _GameBoardBodyState createState() => _GameBoardBodyState();

}

class _GameBoardBodyState extends State<GameBoardBody> {
  // List<List<Tile>> board;

  static const Duration _duration = Duration(milliseconds: 150);
  static const Curve _curve = Curves.easeInOut;
  static const EdgeInsets _padding = const EdgeInsets.all(10);

  Offset panOffset = Offset(0, 0);

  GlobalKey gameOverKey, youWinKey;

  GameBoardState _previousBoard;

  FocusNode keyboardListenerFocusNode;

  @override
  void initState() {
    super.initState();
    context.read<GameBoardBloc>().add(
      GameBoardStartedEvent()
    );
    keyboardListenerFocusNode = FocusNode();
    gameOverKey = GlobalKey();
    youWinKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    var gameBoardBloc = context.watch<GameBoardBloc>();
    var board = gameBoardBloc.state;
    var previousBoard = _previousBoard;
    _previousBoard = board;
    if(board == null)
      return Center(
        child: CircularProgressIndicator()
      );
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: borderRadius
          ),
          padding: _padding,
          child: LayoutBuilder(
              builder: (context, constraints){
                final size = min(constraints.maxWidth/board.x, constraints.maxHeight/board.y);

                final padding = EdgeInsets.all(size * 0.05);
                return Listener(
                  onPointerDown: onPointerDown,
                  onPointerMove: (details) => onPointerMove(details, size/16),
                  onPointerUp: onPointerUp,
                  child: Container(
                    width: size * board.x,
                    height: size * board.y,
                    color: Colors.transparent,
                    child: RawKeyboardListener(
                      autofocus: true,
                      focusNode: keyboardListenerFocusNode,
                      onKey: onKey,
                      child: Stack(
                        children: [
                          for (var row in board.board.asMap().entries)
                            for (var col in row.value.asMap().entries)
                              AnimatedPositioned(
                                left: size * col.key,
                                top: size * row.key,
                                duration: _duration,
                                curve: _curve,
                                child: Container(
                                  width: size,
                                  height: size,
                                  padding: padding,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).accentColor,
                                      borderRadius: borderRadius
                                    ),                        // margin: _padding,
                                  ),
                                ),
                              ),

                          for (var row in board.board.asMap().entries)
                            for (var col in row.value.asMap().entries)
                              for (var tile in col.value)
                                AnimatedPositioned(
                                  key: ValueKey(tile),
                                  left: size * col.key,
                                  top: size * row.key,
                                  duration: _duration,
                                  curve: _curve,
                                  child: Container(
                                      width: size,
                                      height: size,
                                      padding: padding,
                                      child: Container(
                                        width: size,
                                        height: size,
                                        child: TileWidget(
                                          // key: ValueKey(tile),
                                            tile: tile
                                        ),
                                      )

                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          ),
        ),
        if(gameBoardBloc.calculateAvailableMoves() == 0)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: _duration,
              builder: (context, value, child) =>
                Opacity(
                  opacity: value,
                  child: GameOverOverlay(
                    key: gameOverKey
                  ),
                ),
            ),
          ),

        if((board?.maxTileValue ?? 0) == GameBoardBloc.winningTileValue &&
            (previousBoard?.maxTileValue ?? 0) < GameBoardBloc.winningTileValue)

          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: _duration,
              builder: (context, value, child) =>
                  Opacity(
                    opacity: value,
                    child: YouWinOverlay(
                      key: gameOverKey
                    ),
                  ),
            ),
          ),
      ],
    );
  }
  void move(MovementDirection direction) async {
    // Provider.of<GameController>(context, listen: false).move(direction, _duration);
    if(gameOverKey.currentState?.mounted ?? false)
      return;

    if(youWinKey.currentState?.mounted ?? false)
      return;

    context.read<GameBoardBloc>().add(
      GameBoardMovedEvent(direction, _duration)
    );
    setState(() {
      // board[0][3] = board[0][2];
      // board[0][2] = Tile(null);
    });
  }

  void onKey(RawKeyEvent event){
    if(event is RawKeyDownEvent){
      switch(event.character){
        case 'ArrowRight':
          move(MovementDirection.right);
          break;
        case 'ArrowLeft':
          move(MovementDirection.left);
          break;
        case 'ArrowUp':
          move(MovementDirection.up);
          break;
        case 'ArrowDown':
          move(MovementDirection.down);
          break;
      }
    }
  }

  void onPanStart(DragStartDetails details){
    panOffset = Offset(0, 0);
  }

  void onPanUpdate(DragUpdateDetails details, double panDistance){
    if(panOffset == null)
      return;

    panOffset = panOffset + details.delta;

    if(panOffset.dx.clamp(-panDistance, panDistance) == panOffset.dx &&
        panOffset.dy.clamp(-panDistance, panDistance) == panOffset.dy)
      return;

    if(panOffset.dx > panDistance) // right
      move(MovementDirection.right);
    else if(panOffset.dx < -panDistance)
      move(MovementDirection.left);
    else if(panOffset.dy > panDistance)
      move(MovementDirection.down);
    else if(panOffset.dy < -panDistance)
      move(MovementDirection.up);

    panOffset = null;
  }

  void onPanEnd(DragEndDetails details){
    print(panOffset);
  }

  void onPointerDown(PointerDownEvent event){
    // print(event);
    keyboardListenerFocusNode.requestFocus();
    // panOffset = Offset(0, 0);
  }

  void onPointerMove(PointerMoveEvent event, double threshold){
    if(panOffset == null)
      return;

    panOffset = panOffset + event.delta;

    if(panOffset.dx.clamp(-threshold, threshold) == panOffset.dx &&
        panOffset.dy.clamp(-threshold, threshold) == panOffset.dy)
      return;

    if(panOffset.dx > threshold) // right
      move(MovementDirection.right);
    else if(panOffset.dx < -threshold)
      move(MovementDirection.left);
    else if(panOffset.dy > threshold)
      move(MovementDirection.down);
    else if(panOffset.dy < -threshold)
      move(MovementDirection.up);

    panOffset = null;
  }

  void onPointerUp(PointerUpEvent event){
    panOffset = Offset(0, 0);
  }
}

class TileWidget extends StatelessWidget {

  final Tile tile;

  const TileWidget({Key key, this.tile}) : super(key: key);

  static const Duration _duration = Duration(milliseconds: 150);
  static const Curve _orphanCurve = Curves.bounceInOut;
  static const Curve _parentCurve = Curves.easeOutBack;

  @override
  Widget build(BuildContext context) {
    if(tile == null)
      return SizedBox();

    if(tile.parents == null)
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: _duration,
        curve: _orphanCurve,
        builder: (context, value, child){
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: TileWidgetContent(tile: tile,),
            ),
          );
        },
      );

    return
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: _duration,
        curve: _parentCurve,
        builder: (context, value, child){
          return Transform.scale(
            scale: value,
            child: Opacity(
                opacity: value.clamp(0, 1),
                child:
                Stack(
                  children: [
                    if(value < 1)
                      for(var parent in tile.parents)
                        Positioned.fill(
                          child: TileWidgetContent(tile: parent,)
                        ),

                    Positioned.fill(
                      child: TileWidgetContent(tile: tile,),
                    )
                  ],
                )
            ),
          );
        },
      );
  }
}

class TileWidgetContent extends StatelessWidget {

  final Tile tile;

  const TileWidgetContent({Key key, this.tile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final _numberPadding = EdgeInsets.symmetric(
            vertical: constraints.maxHeight * 0.15,
            horizontal: constraints.maxWidth * 0.025
          );
          return Container(
            decoration: BoxDecoration(
              color: tile?.color ?? Colors.white,
              borderRadius: borderRadius
            ),
            child: Padding(
              padding: _numberPadding,
              child: FittedBox(
                child: Text(
                  tile?.value?.toString() ?? '',
                  style: TextStyle(
                    color: (tile?.dark ?? false) ? Colors.white : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}

class GameOverOverlay extends StatelessWidget {

  const GameOverOverlay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: borderRadius
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Game over!", style: Theme.of(context).textTheme.headline3.copyWith(
              fontWeight: FontWeight.bold
            ),),
            SizedBox(
              height: 15,
            ),
            TextButton(
              onPressed: () => resetBoard(context),
              child: Text("Try again", style: Theme.of(context).textTheme.headline6.copyWith(
                color: Theme.of(context).scaffoldBackgroundColor
              ),)
            )
          ],
        ),
      ),
    );
  }

  void resetBoard(BuildContext context){
    // Provider.of<GameController>(context, listen: false).initGame();
    var bloc = context.read<GameBoardBloc>();
    bloc.add(GameBoardResetEvent());
  }
}

class YouWinOverlay extends StatelessWidget {

  const YouWinOverlay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: borderRadius
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You win!", style: Theme.of(context).textTheme.headline3.copyWith(
              fontWeight: FontWeight.bold
            ),),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => continueBoard(context),
                  child: Text("Continue", style: Theme.of(context).textTheme.headline6.copyWith(
                      color: Theme.of(context).scaffoldBackgroundColor
                  ),)
                ),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                    onPressed: () => resetBoard(context),
                    child: Text("Restart", style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context).scaffoldBackgroundColor
                    ),)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void resetBoard(BuildContext context){
    var bloc = context.read<GameBoardBloc>();
    bloc.add(GameBoardResetEvent());
  }

  void continueBoard(BuildContext context){
    var bloc = context.read<GameBoardBloc>();
    bloc.add(GameBoardContinuedEvent());
  }
}
