import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:vector_math/vector_math_64.dart' as vector64;

class MyMinimapComponent extends PositionComponent {
  List<GameRoomData> roomsData;
  int? currentRoomIndex;
  int? currentRoomPositionindex;

  MyMinimapComponent({
    required this.roomsData,
    required this.currentRoomIndex,
    required this.currentRoomPositionindex,
    required super.size,
    required super.position
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override 
  void render(Canvas canvas) {
    super.render(canvas);

    // background
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ), 
      Paint()..color = Colors.white
    );

    _drawTables(canvas);
    _drawPlayerHotSpots(canvas);
    _drawRoomDoors(canvas);
  }

  void _drawTables(Canvas canvas){
    // create and draw the tables //

    // create base L-shape
    Path lShapedPath = Path();
    lShapedPath.moveTo(0,0);
    lShapedPath.lineTo(width,0);
    lShapedPath.lineTo(width,height/2);
    lShapedPath.lineTo(width/2,height/2);
    lShapedPath.lineTo(width/2,height);
    lShapedPath.lineTo(0,height);
    lShapedPath.close();

    // matrices to transform the tables
    final vector64.Matrix4 rotationMat = vector64.Matrix4.rotationZ(pi/2);
    final vector64.Matrix4 shrinkMat = vector64.Matrix4.identity()..scale(0.4);
    final Float64List rotationBuffer = rotationMat.storage;
    final Float64List shrinkBuffer = shrinkMat.storage;

    // create the 4 different tables
    lShapedPath = lShapedPath.transform(shrinkBuffer);
    lShapedPath = lShapedPath.shift(Offset(-width/2.1, -height/2.1));

    Path tableApath = lShapedPath;
    Path tableBpath = tableApath.transform(rotationBuffer);
    Path tableCpath = tableBpath.transform(rotationBuffer);
    Path tableDpath = tableCpath.transform(rotationBuffer);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width/100;

    // draw the tables
    canvas.drawPath(tableApath, paint);
    canvas.drawPath(tableBpath, paint);
    canvas.drawPath(tableCpath, paint);
    canvas.drawPath(tableDpath, paint);
  }

  void _drawPlayerHotSpots(Canvas canvas){
    Paint circlePaint = Paint()
     ..color = Color.fromARGB(255, 255, 50, 50);
    double circleSize = width/50;
    List<Offset> highlightCirclePositionOptions = [];

    vector64.Vector4 baseOffset = vector64.Vector4(0,-height/10,0,0);
    vector64.Matrix4 rotationMat = vector64.Matrix4.rotationZ(pi/2);

    highlightCirclePositionOptions.add(Offset(baseOffset.x, baseOffset.y));
    canvas.drawCircle(Offset(baseOffset.x, baseOffset.y), circleSize, circlePaint);
    baseOffset = rotationMat.transform(baseOffset);
    highlightCirclePositionOptions.add(Offset(baseOffset.x, baseOffset.y));
    canvas.drawCircle(Offset(baseOffset.x, baseOffset.y), circleSize, circlePaint);
    baseOffset = rotationMat.transform(baseOffset);
    highlightCirclePositionOptions.add(Offset(baseOffset.x, baseOffset.y));
    canvas.drawCircle(Offset(baseOffset.x, baseOffset.y), circleSize, circlePaint);
    baseOffset = rotationMat.transform(baseOffset);
    highlightCirclePositionOptions.add(Offset(baseOffset.x, baseOffset.y));
    canvas.drawCircle(Offset(baseOffset.x, baseOffset.y), circleSize, circlePaint);
    baseOffset = rotationMat.transform(baseOffset);

    // draw the current player position
    if (currentRoomPositionindex != null){
      Offset highlightCirclePosition = highlightCirclePositionOptions[currentRoomPositionindex!];
      canvas.drawCircle(
        highlightCirclePosition, 
        circleSize*2, 
        circlePaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = width/100
      );
    }
  }

  void _drawRoomDoors(Canvas canvas){
    Paint doorPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = width/100
      ..color = Color.fromARGB(255, 255, 192, 99);
    double doorSize = width/10;

    // create base door shape
    Path doorShapedPath = Path();
    doorShapedPath.moveTo(0,0);
    doorShapedPath.lineTo(0,doorSize/4);
    doorShapedPath.lineTo(doorSize,doorSize/4);
    doorShapedPath.lineTo(doorSize,0);
    // doorShapedPath.close();

    // matrices to transform the tables
    final vector64.Matrix4 rotationMat = vector64.Matrix4.rotationZ(pi/2);
    final vector64.Matrix4 shrinkMat = vector64.Matrix4.identity()..scale(0.99);
    final Float64List rotationBuffer = rotationMat.storage;
    final Float64List shrinkBuffer = shrinkMat.storage;

    // create the 4 different tables
    doorShapedPath = doorShapedPath.transform(shrinkBuffer);
    doorShapedPath = doorShapedPath.shift(Offset(-doorSize/2, -height/2));

    Path doorApath = doorShapedPath;
    Path doorBpath = doorApath.transform(rotationBuffer);
    Path doorCpath = doorBpath.transform(rotationBuffer);
    Path doorDpath = doorCpath.transform(rotationBuffer);

    // draw the tables
    canvas.drawPath(doorApath, doorPaint);
    canvas.drawPath(doorBpath, doorPaint);
    canvas.drawPath(doorCpath, doorPaint);
    canvas.drawPath(doorDpath, doorPaint);
  }
}