import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:project57/components/item_component.dart';
import 'package:tuple/tuple.dart';

class MyTableComponent extends PositionComponent {
  late GameTable table;
  List<GameRoomData> rooms;
  int roomIndex;
  int tableIndex;
  int relativeRotationIndex;
  bool debug;
  bool showGridOverlay;

  // basic drawing info
  late Path path;
  late List<Offset> points;

  MyTableComponent({
    required super.size,
    required super.position,
    required this.rooms,
    required this.roomIndex,
    required this.tableIndex,
    required this.relativeRotationIndex,
    this.debug = false,
    this.showGridOverlay = false
  }){
    table = rooms[roomIndex].tables[tableIndex];

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

    anchor = Anchor.center;

    for (GameItem item in table.childItems){
      Offset positionOffset = 
        item.posOffset 
        + points[item.pos.item2 * (GameTable.cellCount-1) + item.pos.item1]
        + Offset(width/2,height/2);
      MyItemComponent itemComponent = MyItemComponent(
        item: item,
        points: points,
        size: Vector2(width/GameTable.cellCount, width/GameTable.cellCount),
        relativeRotationIndex: relativeRotationIndex,
        position: Vector2(positionOffset.dx,positionOffset.dy),
        baseOffset: Offset(width/2,height/2)
      );
      add(itemComponent);
    }
  }

  void updateTableIndex(int newIndex){
    tableIndex = newIndex;
    table = rooms[roomIndex].tables[tableIndex];

    children.clear();
    onLoad();
  }

  @override
  void render(Canvas canvas){
    super.render(canvas);

    canvas.translate(width/2, height/2);

    canvas.drawPath(
      path, 
      Paint()
        ..color = Colors.white
    );

    if (debug){
      for (Offset point in points){
        Offset relativeOffset = Offset(point.dx/(width/GameTable.cellCount),point.dy/(height/GameTable.cellCount));
        Tuple2<int,int> pos = Tuple2(
          (4+relativeOffset.dx).round().clamp(0, 8),
          (4+relativeOffset.dy).round().clamp(0, 8),
        );

        Tuple2<int,int> badness = getBadness(relativeRotationIndex, pos);

        if (
          !(badness.item1 >= 0 && badness.item2 >= 0)
        ){
          canvas.drawCircle(point, width/200, Paint()..color = Colors.black);
        }
      }
    }

    if (showGridOverlay){
      for (Offset point in points){
        Offset relativeOffset = Offset(point.dx/(width/GameTable.cellCount),point.dy/(height/GameTable.cellCount));
        Tuple2<int,int> pos = Tuple2(
          (4+relativeOffset.dx).round().clamp(0, 8),
          (4+relativeOffset.dy).round().clamp(0, 8),
        );

        Tuple2<int,int> badness = getBadness(relativeRotationIndex, pos);

        if (
          !(badness.item1 >= 0 && badness.item2 >= 0)
        ){
          canvas.drawRect(Rect.fromCenter(center: point, width: width/GameTable.cellCount, height: width/GameTable.cellCount), 
            Paint()
              ..color = Colors.grey
              ..style = PaintingStyle.stroke
              ..strokeWidth = width/300
          );
        } else {

        }
      }
    }

    canvas.drawPath(
      path, Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );

    canvas.translate(-width/2, -height/2);
  }
}