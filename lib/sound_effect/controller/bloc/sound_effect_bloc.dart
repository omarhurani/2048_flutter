import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_2048/sound_effect/controller/event/sound_effect_event.dart';
import 'package:game_2048/sound_effect/model/SoundEffect.dart';
import 'package:game_2048/sound_effect/repo/sound_settings_repo.dart';

class SoundEffectBloc extends Bloc<SoundEffectEvent, bool> {
  SoundEffectBloc([this._soundSettingsRepository]) : super(null) {
    _audioPlayer = AudioPlayer();
    add(SoundEffectEvent.initialize);
  }

  AudioPlayer _audioPlayer;
  SoundSettingsRepository _soundSettingsRepository;

  @override
  Stream<bool> mapEventToState(SoundEffectEvent event) async* {
    SoundEffect soundEffect;
    switch(event){
      case SoundEffectEvent.initialize:
        yield await initialize();
        return;
      case SoundEffectEvent.soundEnabledToggled:
        yield (!(state ?? true));
        return;
      case SoundEffectEvent.tileMoved:
        soundEffect = SoundEffect.tileMovedSoundEffect;
        break;
      case SoundEffectEvent.tileMerged:
        soundEffect = SoundEffect.tileMergedSoundEffect;
        break;
      case SoundEffectEvent.newTileMerged:
        soundEffect = SoundEffect.newTileMergedSoundEffect;
        break;
      default:
    }
    if(soundEffect != null && (state ?? true)){
      _audioPlayer.play(
        soundEffect.url,
        isLocal: soundEffect.isLocal,
        volume: 0.1,
      ).catchError((_){});
    }
  }

  Future<bool> initialize() async{
    if(_soundSettingsRepository == null)
      return true;

    SoundEffect.values.forEach((element) {
      _audioPlayer.setUrl(element.url);
    });

    return await _soundSettingsRepository.loadSoundEnabledState();

  }

  @override
  void onChange(Change<bool> change) {
    super.onChange(change);
    if(_soundSettingsRepository != null)
      _soundSettingsRepository.saveSoundEnabledState(change.nextState);
  }

}
