import 'package:flutter/material.dart';
import 'package:game_2048/utils/theme.dart';
import 'home_screen/view/home_screen_view.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: theme,
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
