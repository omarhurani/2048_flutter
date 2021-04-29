import 'package:flutter/foundation.dart';

class SoundEffect{
  final String _url;
  final bool isLocal;

  const SoundEffect._(String url, {this.isLocal = false}) : _url = url;

  static const SoundEffect newTileMergedSoundEffect = SoundEffect._('assets/new-merge-sound.mp3',),
    tileMergedSoundEffect = SoundEffect._('assets/merge-sound.mp3',),
    tileMovedSoundEffect = SoundEffect._('assets/movement-sound.mp3',);

  String get url => './${kReleaseMode ? "assets/" : ""}$_url';
}