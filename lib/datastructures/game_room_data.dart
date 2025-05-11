import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:uuid/uuid.dart';
import 'package:tuple/tuple.dart';

class GameRoomData extends ChangeNotifier {
  // locality and identity
  final String id = Uuid().v1();
  late Tuple2<int,int> pos;

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
        GameTable.blank(0),
        GameTable.blank(1),
        GameTable.blank(2),
        GameTable.blank(3),
        // GameTable(relativeRotationIndex: 1),
        // GameTable(relativeRotationIndex: 2),
        // GameTable(relativeRotationIndex: 3),
      ];

      for (GameTable table in this.tables){
        table.addListener(notifyListeners);
      }
    }
  }
}