import 'dart:math';

import 'package:event_bus_arch/event_bus_arch.dart';
import 'package:life_game/main.dart';

class LifeCell {
  int cellLife = 0;
  int cellEmpty = 0;
}

class LifeGame {
  ///1 bit life or empty in current turn
  ///2 bit for calculate
  List<List<int>> currentMap = [];
  final int width;
  final int height;
  bool onEndless = false;
  bool isStart = false;
  bool _isRun = false;
  bool _isBus = false;
  LifeGame({this.width = 3, this.height = 3}) {
    for (var i = 0; i < width; i++) {
      currentMap.add(List<int>.filled(height, 0));
    }
  }

  /// luck 0.0-1.0
  void generateLife({int? lifersMax, double luck = 0.2}) {
    isStart = false;

    lifersMax ??= height * width;

    int count = 0;
    for (var i = 0; i < width; i++) {
      for (var i1 = 0; i1 < height; i1++) {
        currentMap[i][i1] = Random().nextInt(101) > 100 * (1 - luck) ? 1 : 0;
        if (currentMap[i][i1] == 1) {
          count++;
        }
        if (count >= lifersMax) return;
      }
    }
  }

  Future<void> stop() async {
    _isRun = false;
    if (!_isBus) {
      await Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return isStart;
      });
    }
  }

  Future<void> startWithBus(
    EventBus bus, {
    int timeINmsec = 100,
  }) async {
    isStart = true;
    _isRun = true;
    _isBus = true;
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: timeINmsec));
      next();
      await Future.delayed(Duration(milliseconds: timeINmsec));
      clearLastSatet();
      if (!_isRun) {
        print('END');
      }
      return _isRun;
    });
  }

  Stream<List<List<int>>> startGame({int timeINmsec = 1000, bool onEndless = false}) async* {
    isStart = true;
    _isRun = true;
    this.onEndless = onEndless;
    while (_isRun) {
      await Future.delayed(Duration(milliseconds: timeINmsec));
      yield next();
      await Future.delayed(Duration(milliseconds: timeINmsec));
      yield clearLastSatet();
    }
    isStart = false;
    _isRun = false;
  }

  void clear() {
    for (var i = 0; i < width; i++) {
      for (var i1 = 0; i1 < height; i1++) {
        currentMap[i][i1] = 0;
        bus.send(currentMap[i][i1], eventName: '$i!$i1');
      }
    }
  }

  List<List<int>> clearLastSatet() {
    bool isDie = true;
    int tmp = 0;
    for (var i = 0; i < width; i++) {
      for (var i1 = 0; i1 < height; i1++) {
        tmp = (currentMap[i][i1] >> 1) & 1;
        if (_isBus && tmp != currentMap[i][i1]) {
          bus.send(tmp, eventName: '$i!$i1');
        }
        currentMap[i][i1] = tmp;

        if (currentMap[i][i1] & 1 == 1) {
          isDie = false;
        }
      }
    }
    if (_isRun) _isRun = !isDie;
    return currentMap;
  }

  ///в пустой (мёртвой) клетке, с которой соседствуют три живые клетки, зарождается жизнь;
  ///если у живой клетки есть две или три живые соседки, то эта клетка продолжает жить;
  ///в противном случае (если живых соседей меньше двух или больше трёх) клетка умирает («от одиночества» или «от перенаселённости»)
  List<List<int>> next() {
    var tmp = 0;
    for (var i = 0; i < width; i++) {
      for (var i1 = 0; i1 < height; i1++) {
        tmp = currentMap[i][i1];
        var c = onEndless ? _analizeEndlessMap(i, i1) : _analize(i, i1);
        if (currentMap[i][i1] & 1 == 1) {
          //Она жива и надо проверить будет ли она жить
          if (c.cellLife == 2 || c.cellLife == 3) {
            //life

            currentMap[i][i1] |= 2;
          } else {
            //die
          }
        } else {
          ///в пустой (мёртвой) клетке, с которой соседствуют три живые клетки, зарождается жизнь;
          if (c.cellLife == 3) {
            currentMap[i][i1] |= 2;
          }
        }
        if (tmp != currentMap[i][i1]) {
          if (_isBus) {
            bus.send(currentMap[i][i1], eventName: '$i!$i1');
          }
        }
      }
    }

    return currentMap;
  }

  ///если карта ограничена рамкой
  LifeCell _analize(int w, int h) {
    LifeCell cell = LifeCell();
    int _w = w - 1;
    int _h = h - 1;
    if (_w < 0) _w = w;
    if (_h < 0) _h = h;
    int _hStart = _h;
    for (int i = 0; _w <= w + 1; i++) {
      for (int i1 = 0; _h <= h + 1; i1++) {
        if (!(_w == w && _h == h)) {
          if (currentMap[_w][_h] & 1 == 1) {
            cell.cellLife++;
          } else {
            cell.cellEmpty++;
          }
        }

        _h++;
        if (_h >= height) break;
      }
      _h = _hStart;
      _w++;
      if (_w >= width) break;
    }
    return cell;
  }

  ///если у нас карта условно бесконечная, тоесть не ограничена полями
  LifeCell _analizeEndlessMap(int w, int h) {
    LifeCell cell = LifeCell();
    int _w = w - 1;
    int _h = h - 1;
    if (_w < 0) _w = width - 1;
    if (_h < 0) _h = height - 1;
    int _hStart = _h;
    for (int i = 0; i < 3; i++) {
      for (int i1 = 0; i1 < 3; i1++) {
        if (!(_w == w && _h == h)) {
          if (currentMap[_w][_h] & 1 == 1) {
            cell.cellLife++;
          } else {
            cell.cellEmpty++;
          }
        }

        _h++;
        if (_h >= height) _h = 0;
      }
      _h = _hStart;
      _w++;
      if (_w >= width) _w = 0;
    }
    return cell;
  }
}
