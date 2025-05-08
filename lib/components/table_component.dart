import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:project57/widgets/item.dart';

class MyTableComponent extends PositionComponent {
  late final GameTable table;
  int relativeRotationIndex;
  bool debug;

  MyTableComponent({
    required super.size,
    required super.position,
    required this.table,
    required this.relativeRotationIndex,
    this.debug = false,
  });

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
  }

  @override
  void render(Canvas canvas){
    super.render(canvas);

    Path path = getLShapedPath(
      width, 
      height,
      rotateByRadians: relativeRotationIndex * pi/2,
      scaleByFactor: 1,
      shiftByOffset: Offset(-width/2, -height/2)
    );

    canvas.drawPath(
      path, Paint()
        ..color = Colors.white
    );

    List<Offset> points = getLShapeGridPoints(
      cellSize: 1/10,
      width: width, 
      height: height,
      rotateByRadians: relativeRotationIndex * pi/2,
      scaleByFactor: 1,
      shiftByOffset: Offset(-width/2, -height/2)
    );

    if (debug){
      for (Offset point in points){
        canvas.drawCircle(point, width/200, Paint()..color = Colors.black);
      }
    }

    for (Offset point in points){
      canvas.drawRect(Rect.fromCenter(center: point, width: width/10, height: width/10), 
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/300
      );
    }

    canvas.drawPath(
      path, Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );
  }
}