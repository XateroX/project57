import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/widgets/item.dart';

class MyTableComponent extends RectangleComponent {
  late final GameTable table;

  MyTableComponent({
    super.size,
    super.paint,
    super.position,
    GameTable? table,
  }) : table = table ?? GameTable.blank();

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    final double smallSize = min(width/6,height/6);
    for (GameItem item in table.childItems){
      final itemComponent = MyItemComponent(
        size: Vector2(smallSize,smallSize), // width and height
        paint: Paint()..color = Colors.blue, // color of the square
        position: Vector2(width/2 - smallSize/2, height/2 - smallSize/2), // position on the canvas
      );
      add(itemComponent);
    }
  }
}