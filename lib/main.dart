import 'package:flutter/material.dart';
import 'package:game_2048/game_board/controller/game_board_controller.dart';
import 'package:game_2048/utils/theme.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'game_board/game_board.dart';
import 'home_screen/view/home_screen_view.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
