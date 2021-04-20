import 'package:flutter/material.dart';

class Tile{
  static const Map<int, TileColor> colors = {
    2: TileColor(Color(0xFFEDE4DA), false),
    4: TileColor(Color(0xFFECDFC7), false),
    8: TileColor(Color(0xFFF2B179),),
    16: TileColor(Color(0xFFF59563),),
    32: TileColor(Color(0xFFE68469),),
    64: TileColor(Color(0xFFE46B4C),),
    128: TileColor(Color(0xFFEACC79),),
    256: TileColor(Color(0xFFEDC850),),
    512: TileColor(Color(0xFFEDC53F),),
    1024: TileColor(Colors.red,),
    2048: TileColor(Colors.green,),
    4096: TileColor(Colors.purple,),
    8192: TileColor(Colors.blue,),
  };

  final int value;
  final Set<Tile> parents;

  const Tile(this.value, {this.parents});

  Color get color => colors[value]?.color ??
      (value == null ? Colors.transparent : Colors.black);

  bool get dark => colors[value]?.dark ??
      (value == null ? false : true);

  @override
  String toString() {
    return value.toString();
  }
}

class TileColor{
  final Color color;
  final bool dark;

  const TileColor(this.color, [this.dark = true]);
}