import 'dart:async';

import 'package:hive/hive.dart';

class HiveBoxProvider{

  final String name;
  Box _box;
  Completer<void> _opened;

  HiveBoxProvider(this.name){
    _initBox();
    _opened = Completer<void>();
  }

  _initBox() async {
    _box = await Hive.openBox(name);
    if(!_opened.isCompleted)
      _opened.complete();
  }

  Future get opened => _opened.future;

  Box get box {
    return _box;
  }

  Future<int> add(value) async {
    await opened;
    return await box.add(value);
  }

  getAt(int index) {
    return box.getAt(index);
  }

  Future put(key, value) async {
    await opened;
    await box.put(key, value);
  }

  get(key) {
    return box.get(key);
  }

}