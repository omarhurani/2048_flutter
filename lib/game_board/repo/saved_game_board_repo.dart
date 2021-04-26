import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:game_2048/game_board/controller/state/game_board_state.dart';
import 'package:game_2048/hive/controller/provider/hive_provider.dart';

class SavedGameBoardRepository {
  final HiveBoxProvider _hiveBox;

  SavedGameBoardRepository() : _hiveBox = HiveBoxProvider('GameBoard');

  static const String _lastSavedGameKey = 'lastSaved';

  void saveGameBoardState(GameBoardState state) async {
    await _hiveBox.opened;
    final key = getKey(state.x, state.y);
    await _hiveBox.put(key, jsonEncode(state.toJson()));
    await _hiveBox.put(_lastSavedGameKey, key);
  }

  Future<GameBoardState> loadGameBoardState([int x, int y]) async {
    await _hiveBox.opened;
    var key;
    if(x != null && y != null){
      key = getKey(x, y);
    }
    else{
      key = _hiveBox.get(_lastSavedGameKey);
      if(key == null)
        return null;
    }
    final boardJsonString = _hiveBox.get(key);
    if(boardJsonString == null)
      return null;
    var boardJson =jsonDecode(boardJsonString);
    return GameBoardState.fromJson(boardJson);
  }

  String getKey(int x, int y){
    return "$x,$y";
  }
}