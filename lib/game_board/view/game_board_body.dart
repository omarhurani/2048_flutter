
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_2048/game_board/controller/game_board_controller.dart';
import 'package:game_2048/game_board/model/movement_direction.dart';
import 'package:game_2048/game_board/model/tile.dart';
import 'package:game_2048/utils/theme.dart';
import 'package:provider/provider.dart';

class GameBoardBody extends StatefulWidget {

  const GameBoardBody({
    Key key,
  }) : super(key: key);


  @override
  _GameBoardBodyState createState() => _GameBoardBodyState();

}

class _GameBoardBodyState extends State<GameBoardBody> {
  // List<List<Tile>> board;

  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeInOut;
  static const EdgeInsets _padding = const EdgeInsets.all(10);

  double size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var game = Provider.of<GameController>(context);
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
                final size = min(constraints.maxWidth/game.columns, constraints.maxHeight/game.rows);

                final padding = EdgeInsets.all(size * 0.05);
                return SizedBox(
                  width: size * game.columns,
                  height: size * game.rows,
                  child: RawKeyboardListener(
                    autofocus: true,
                    focusNode: FocusNode(),
                    onKey: onKey,
                    child: Stack(
                      children: [
                        for (var row in game.board.asMap().entries)
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

                        for (var row in game.board.asMap().entries)
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
                );
              }
          ),
        ),
        if(game.calculateAvailableMoves() == 0)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: _duration,
              builder: (context, value, child) =>
                  Opacity(
                    opacity: value,
                    child: GameOverScreen(),
                  ),
            ),
          ),
      ],
    );
  }
  void move(MovementDirection direction) async {
    Provider.of<GameController>(context, listen: false).move(direction, _duration);
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
}

class TileWidget extends StatelessWidget {

  final Tile tile;

  const TileWidget({Key key, this.tile}) : super(key: key);

  static const Duration _duration = Duration(milliseconds: 250);
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

class GameOverScreen extends StatelessWidget {
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
    Provider.of<GameController>(context, listen: false).initGame();
  }
}
