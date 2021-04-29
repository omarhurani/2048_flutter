import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_2048/sound_effect/controller/event/sound_effect_event.dart';
import 'package:game_2048/sound_effect/model/SoundEffect.dart';

class SoundEffectBloc extends Bloc<SoundEffectEvent, void> {
  SoundEffectBloc() : super(null) {
    _audioPlayer = AudioPlayer();
  }

  AudioPlayer _audioPlayer;

  @override
  Stream<void> mapEventToState(SoundEffectEvent event) async* {
    SoundEffect soundEffect;
    switch(event){
      case SoundEffectEvent.tileMoved:
        soundEffect = SoundEffect.tileMovedSoundEffect;
        break;
      case SoundEffectEvent.tileMerged:
        soundEffect = SoundEffect.tileMergedSoundEffect;
        break;
      case SoundEffectEvent.newTileMerged:
        soundEffect = SoundEffect.newTileMergedSoundEffect;
        break;
    }
    if(soundEffect != null){
      _audioPlayer.play(
        soundEffect.url,
        isLocal: soundEffect.isLocal,
        volume: 0.1,
      );
    }
  }
}
