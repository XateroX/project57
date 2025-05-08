import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/components/table_component.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:vector_math/vector_math_64.dart' as vector64;

class MyMinimapComponent extends PositionComponent {
  List<GameRoomData> roomsData;
  int? currentRoomIndex;
  int? currentRoomPositionindex;
  bool debug;
  bool showGridOverlay;

  int cellRatio = 10;
  double scaleFactor = 0.4;
  late double localCellSize;

  MyMinimapComponent({
    required this.roomsData,
    required this.currentRoomIndex,
    required this.currentRoomPositionindex,
    required super.size,
    required super.position,
    this.showGridOverlay = false,
    this.debug = false
  }){
    localCellSize = scaleFactor * width/cellRatio;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    double squareSize = min(width,height); 

    MyTableComponent tableA = MyTableComponent(
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(-squareSize /4, -squareSize /4),
      table: roomsData[0].tables[0],
      relativeRotationIndex: 0,
      showGridOverlay: showGridOverlay,
      debug: debug
    );
    MyTableComponent tableB = MyTableComponent(
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(squareSize /4, -squareSize /4),
      table: roomsData[0].tables[1],
      relativeRotationIndex: 1,
      showGridOverlay: showGridOverlay,
      debug: debug
    );
    MyTableComponent tableC = MyTableComponent(
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(squareSize /4, squareSize /4),
      table: roomsData[0].tables[2],
      relativeRotationIndex: 2,
      showGridOverlay: showGridOverlay,
      debug: debug
    );
    MyTableComponent tableD = MyTableComponent(
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(-squareSize /4, squareSize /4),
      table: roomsData[0].tables[3],
      relativeRotationIndex: 3,
      showGridOverlay: showGridOverlay,
      debug: debug
    );
    addAll([tableA, tableB, tableC, tableD]);
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

    _drawPlayerHotSpots(canvas);
    _drawRoomDoors(canvas);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ), 
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );
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

  void _showDebugInfo(Canvas canvas){
    List<Offset> pointsA = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: 0,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );
    List<Offset> pointsB = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: pi/2,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );
    List<Offset> pointsC = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: 2 * pi/2,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );
    List<Offset> pointsD = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: 3 * pi/2,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );

    for (Offset point in pointsA){
      canvas.drawCircle(point, scaleFactor * width/200, Paint()..color = Colors.black);
    }
    for (Offset point in pointsB){
      canvas.drawCircle(point, scaleFactor * width/200, Paint()..color = Colors.black);
    }
    for (Offset point in pointsC){
      canvas.drawCircle(point, scaleFactor * width/200, Paint()..color = Colors.black);
    }
    for (Offset point in pointsD){
      canvas.drawCircle(point, scaleFactor * width/200, Paint()..color = Colors.black);
    }
  }

  void _showGridOverlay(Canvas canvas){
    List<Offset> pointsA = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: 0,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );
    List<Offset> pointsB = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: pi/2,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );
    List<Offset> pointsC = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: 2 * pi/2,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );
    List<Offset> pointsD = getLShapeGridPoints(
      cellSize: 1/cellRatio,
      width: width, 
      height: height,
      rotateByRadians: 3 * pi/2,
      scaleByFactor: scaleFactor,
      shiftByOffset: Offset(-width/2.1, -height/2.1)
    );

    for (List<Offset> pointList in [pointsA, pointsB, pointsC, pointsD]){
      for (Offset point in pointList){
        canvas.drawRect(Rect.fromCenter(center: point, width: localCellSize, height: localCellSize), 
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = scaleFactor * width/300
        );
      }
    }
  }
}