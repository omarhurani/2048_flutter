import 'package:flutter/material.dart';

class Tile{
  static const Map<int, TileColor> colors = {
    2:      TileColor(Color(0xFFEDE4DA), false),
    4:      TileColor(Color(0xFFECDFC7), false),
    8:      TileColor(Color(0xFFF2B179),),
    16:     TileColor(Color(0xFFF59563),),
    32:     TileColor(Color(0xFFE68469),),
    64:     TileColor(Color(0xFFE46B4C),),
    128:    TileColor(Color(0xFFEACC79),),
    256:    TileColor(Color(0xFFEDC850),),
    512:    TileColor(Color(0xFFEDC53F),),
    1024:   TileColor(Color(0xFFF4BF3D)),
    2048:   TileColor(Color(0xFFF6BC2B)),
    4096:   TileColor(Color(0xFFFF4F3F)),
    8192:   TileColor(Color(0xFFF83222)),
    16384:  TileColor(Color(0xFFC02820)),
    32768:  TileColor(Color(0xFF6DAFDA), false),
    65536:  TileColor(Color(0xFF497EBB)),
    131072: TileColor(Color(0xFF005D9E)),
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

  Map<String, dynamic> toJson() => {'value': value};
  factory Tile.fromJson(Map<String, dynamic> json) => Tile(json['value']);

}

class TileColor{
  final Color color;
  final bool dark;

  const TileColor(this.color, [this.dark = true]);
}