import 'package:flutter/material.dart';
import 'package:game_2048/game_board/controller/game_board_controller.dart';
import 'package:game_2048/game_board/view/game_board_view.dart';
import 'package:provider/provider.dart';

import 'home_screen_header.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ChangeNotifierProvider<GameController>(
          create: (_) => GameController(4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HomeScreenHeader(),
              Flexible(
                child: GameBoard()
              ),
              SizedBox(
                height: 50,
              ),
            ],
          )
        ),
      ),
    );
  }
}
