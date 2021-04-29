import 'package:flutter/foundation.dart';

class SoundEffect{
  final String _url;
  final bool isLocal;

  const SoundEffect._(String url, {this.isLocal = false}) : _url = url;

  static const SoundEffect
    newTileMergedSoundEffect = SoundEffect._('https://firebasestorage.googleapis.com/v0/b/omar-hurani-2048.appspot.com/o/new-merge-sound.mp3?alt=media&token=e431bc78-a02e-4be4-b6bc-301d90cb9a79',),
    tileMergedSoundEffect = SoundEffect._('https://firebasestorage.googleapis.com/v0/b/omar-hurani-2048.appspot.com/o/merge-sound.mp3?alt=media&token=9fce264b-83a5-489b-add2-313c0fa6f6ab',),
    tileMovedSoundEffect = SoundEffect._('https://firebasestorage.googleapis.com/v0/b/omar-hurani-2048.appspot.com/o/movement-sound.mp3?alt=media&token=582f6ce1-3a3d-4e48-8d53-c8fb1ed9d64a',);

  static const List<SoundEffect> values = [
    newTileMergedSoundEffect,
    tileMergedSoundEffect,
    tileMovedSoundEffect,
  ];

  String get url => _url;
      // './${kReleaseMode ? "assets/" : ""}$_url';
}