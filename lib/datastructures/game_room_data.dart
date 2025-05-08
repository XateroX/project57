import 'package:flame/game.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:uuid/uuid.dart';
import 'package:tuple/tuple.dart';

class GameRoomData {
  // locality and identity
  final String id = Uuid().v1();
  late Tuple2 pos;

  // game state
  late List<GameTable> tables;

  GameRoomData({
    List<GameTable>? tables,
    this.pos = const Tuple2(0,0),
  }) {
    if (tables != null && tables.length == 4) {
      this.tables = tables;
    } else {
      this.tables = [
        GameTable(),
        GameTable(),
        GameTable(),
        GameTable(),
      ];
    }
  }
}