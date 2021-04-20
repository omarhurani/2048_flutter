import 'package:flutter/material.dart';
import 'package:game_2048/game_board/controller/game_board_controller.dart';
import 'package:game_2048/utils/theme.dart';
import 'package:provider/provider.dart';

class GameBoardHeader extends StatefulWidget {
  @override
  _GameBoardHeaderState createState() => _GameBoardHeaderState();
}

class _GameBoardHeaderState extends State<GameBoardHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
                text: "2048",
                style: Theme.of(context).textTheme.headline1.copyWith(
                    height: 1
                ),
                children: [
                  TextSpan(
                    text: "\nby Omar Hurani",
                    style: Theme.of(context).textTheme.headline6,
                  )
                ]
            ),
          ),

          Row(
            children: [
              Consumer<GameController>(
                builder: (context, provider, child) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: provider.score.toDouble()),
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return ScoreIndicator(
                        title: "Score",
                        score: value.toInt(),
                      );
                    }
                ),
              ),

              Consumer<GameController>(
                builder: (context, provider, child) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: provider.bestScore.toDouble()),
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return ScoreIndicator(
                        title: "Best Score",
                        score: value.toInt(),
                      );
                    }
                ),
              )
            ].map<Widget>((e) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: e,
            )).toList(),
          )
        ],
      ),
    );
  }
}

class ScoreIndicator extends StatelessWidget {
  final String title;
  final int score;

  const ScoreIndicator({
    Key key,
    @required this.title,
    @required this.score
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: borderRadius
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 2.5,
          horizontal: 15
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title ?? '', style: Theme.of(context).textTheme.headline6.copyWith(
              color: Theme.of(context).scaffoldBackgroundColor
          ),),
          Text(score?.toString() ?? '', style: Theme.of(context).textTheme.bodyText1.copyWith(
              fontSize: 24
          ),),

        ],
      ),
    );
  }
}
