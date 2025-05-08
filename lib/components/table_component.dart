import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:project57/components/item_component.dart';

class MyTableComponent extends PositionComponent {
  late final GameTable table;
  int relativeRotationIndex;
  bool debug;
  bool showGridOverlay;

  // basic drawing info
  late Path path;
  late List<Offset> points;

  MyTableComponent({
    required super.size,
    required super.position,
    required this.table,
    required this.relativeRotationIndex,
    this.debug = false,
    this.showGridOverlay = false
  }){
    path = getLShapedPath(
      width, 
      height,
      rotateByRadians: relativeRotationIndex * pi/2,
      scaleByFactor: 1,
      shiftByOffset: Offset(-width/2, -height/2)
    );

    points = getLShapeGridPoints(
      cellSize: 1/GameTable.cellCount,
      width: width, 
      height: height,
      rotateByRadians: relativeRotationIndex * pi/2,
      scaleByFactor: 1,
      shiftByOffset: Offset(-width/2, -height/2)
    );
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    for (GameItem item in table.childItems){
      Offset positionOffset = item.posOffset + points[item.pos.item1 * GameTable.cellCount + item.pos.item2];
      MyItemComponent itemComponent = MyItemComponent(
        item: item,
        points: points,
        size: Vector2(width/GameTable.cellCount, width/GameTable.cellCount), 
        paint: Paint()..color = Colors.blue,
        position: Vector2(positionOffset.dx,positionOffset.dy)
      );
      add(itemComponent);
    }
  }

  @override
  void render(Canvas canvas){
    super.render(canvas);

    canvas.drawPath(
      path, Paint()
        ..color = Colors.white
    );

    if (debug){
      for (Offset point in points){
        canvas.drawCircle(point, width/200, Paint()..color = Colors.black);
      }
    }

    if (showGridOverlay){
      for (Offset point in points){
        canvas.drawRect(Rect.fromCenter(center: point, width: width/GameTable.cellCount, height: width/GameTable.cellCount), 
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = width/300
        );
      }
    }

    canvas.drawPath(
      path, Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );
  }
}