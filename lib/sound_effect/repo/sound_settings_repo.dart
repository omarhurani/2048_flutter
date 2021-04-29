import 'package:game_2048/hive/controller/provider/hive_provider.dart';

class SoundSettingsRepository {
  final HiveBoxProvider _hiveBox;

  SoundSettingsRepository() : _hiveBox = HiveBoxProvider('SoundSettings');

  static const String _soundEnabledKey = 'sound-enabled';

  void saveSoundEnabledState(bool muted) async {
    await _hiveBox.opened;
    await _hiveBox.put(_soundEnabledKey, muted);
  }

  Future<bool> loadSoundEnabledState() async {
    await _hiveBox.opened;
    return _hiveBox.get(_soundEnabledKey) ?? true;
  }

}