import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:project57/components/table_component.dart';
import 'package:project57/datastructures/game_overall_data.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:vector_math/vector_math_64.dart' as vector64;

class MyMinimapComponent extends PositionComponent with TapCallbacks {
  // @override
  // bool debugMode = true;
  
  void Function(int) setCurrentRoomPositionindex;
  void Function(int) moveToRoomIndex;
  GameOverallData gameData;
  List<GameRoomData> roomsData;
  int? currentRoomIndex;
  int? currentRoomPositionindex;
  bool debug;
  bool showGridOverlay;

  int cellRatio = 10;
  double scaleFactor = 0.4;
  late double localCellSize;

  MyMinimapComponent({
    required this.gameData,
    required this.setCurrentRoomPositionindex,
    required this.moveToRoomIndex,
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
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // print('Tapped on: $this');
    print('Position: ${event.localPosition}');

    vector64.Vector4 baseOffset = vector64.Vector4(absoluteCenter.x-absoluteTopLeftPosition.x,absoluteCenter.y-absoluteTopLeftPosition.y,0,0);
    vector64.Vector4 pointerOffset = vector64.Vector4(0,-height/10,0,0);
    vector64.Matrix4 rotationMat = vector64.Matrix4.rotationZ(pi/2);
    
    vector64.Vector4 buttonAOffset = baseOffset + pointerOffset;
    pointerOffset.applyMatrix4(rotationMat);
    vector64.Vector4 buttonBOffset = baseOffset + pointerOffset;
    pointerOffset.applyMatrix4(rotationMat);
    vector64.Vector4 buttonCOffset = baseOffset + pointerOffset;
    pointerOffset.applyMatrix4(rotationMat);
    vector64.Vector4 buttonDOffset = baseOffset + pointerOffset;


    pointerOffset = vector64.Vector4(0,-height/2,0,0);
    
    vector64.Vector4 doorEOffset = baseOffset + pointerOffset;
    pointerOffset.applyMatrix4(rotationMat);
    vector64.Vector4 doorFOffset = baseOffset + pointerOffset;
    pointerOffset.applyMatrix4(rotationMat);
    vector64.Vector4 doorGOffset = baseOffset + pointerOffset;
    pointerOffset.applyMatrix4(rotationMat);
    vector64.Vector4 doorHOffset = baseOffset + pointerOffset;
    
    // red position buttons
    if (event.localPosition.distanceTo(Vector2(buttonAOffset.x, buttonAOffset.y)) < width/50) {
      print("CLICKED A");
      setCurrentRoomPositionindex(0);
      currentRoomPositionindex = 0;
    }
    if (event.localPosition.distanceTo(Vector2(buttonBOffset.x, buttonBOffset.y)) < width/50) {
      print("CLICKED B");
      setCurrentRoomPositionindex(1);
      currentRoomPositionindex = 1;
    }
    if (event.localPosition.distanceTo(Vector2(buttonCOffset.x, buttonCOffset.y)) < width/50) {
      print("CLICKED C");
      setCurrentRoomPositionindex(2);
      currentRoomPositionindex = 2;
    }
    if (event.localPosition.distanceTo(Vector2(buttonDOffset.x, buttonDOffset.y)) < width/50) {
      print("CLICKED D");
      setCurrentRoomPositionindex(3);
      currentRoomPositionindex = 3;
    }

    // door buttons
    if (event.localPosition.distanceTo(Vector2(doorEOffset.x, doorEOffset.y)) < width/25) {
      print("CLICKED E");
      moveToRoomIndex(0);
    }
    if (event.localPosition.distanceTo(Vector2(doorFOffset.x, doorFOffset.y)) < width/25) {
      print("CLICKED F");
      moveToRoomIndex(1);
    }
    if (event.localPosition.distanceTo(Vector2(doorGOffset.x, doorGOffset.y)) < width/25) {
      print("CLICKED G");
      moveToRoomIndex(2);
    }
    if (event.localPosition.distanceTo(Vector2(doorHOffset.x, doorHOffset.y)) < width/25) {
      print("CLICKED H");
      moveToRoomIndex(3);
    }
  }

  void _gameDataChanged(){
    if (
      gameData.currentRoomIndex != currentRoomIndex
    ){
      currentRoomIndex = gameData.currentRoomIndex;

      removeAll(children);
      _addChildComponents();
    }
    currentRoomPositionindex = gameData.currentRoomPositionindex.value;
  }


  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
    gameData.addListener(_gameDataChanged);
    _addChildComponents();
  }

  void _addChildComponents(){
    double squareSize = min(width,height); 
    final MyTableComponent tableA = MyTableComponent(
      gameData: gameData,
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(-squareSize /4, -squareSize /4) + Vector2(width/2,height/2),
      tableIndex: 0,
      relativeRotationIndex: 0,
      showGridOverlay: showGridOverlay,
      debug: debug,
      minifiedMode: true,
    );
    final MyTableComponent tableB = MyTableComponent(
      gameData: gameData,
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(squareSize /4, -squareSize /4) + Vector2(width/2,height/2),
      tableIndex: 1,
      relativeRotationIndex: 1,
      showGridOverlay: showGridOverlay,
      debug: debug,
      minifiedMode: true,
    );
    final MyTableComponent tableC = MyTableComponent(
      gameData: gameData,
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(squareSize /4, squareSize /4) + Vector2(width/2,height/2),
      tableIndex: 2,
      relativeRotationIndex: 2,
      showGridOverlay: showGridOverlay,
      debug: debug,
      minifiedMode: true,
    );
    final MyTableComponent tableD = MyTableComponent(
      gameData: gameData,
      size: Vector2(scaleFactor * squareSize, scaleFactor * squareSize),
      position: Vector2(-squareSize /4, squareSize /4) + Vector2(width/2,height/2),
      tableIndex: 3,
      relativeRotationIndex: 3,
      showGridOverlay: showGridOverlay,
      debug: debug,
      minifiedMode: true,
    );
    addAll([tableA, tableB, tableC, tableD]);
  }

  @override 
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.translate(width/2, height/2);

    // _renderStyleDebug(canvas);
    _renderStyleMinimal(canvas);

    canvas.translate(-width/2, -height/2);
  }

  void _renderStyleDebug(Canvas canvas){
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
    _drawSummaryArea(canvas);

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

  void _renderStyleMinimal(Canvas canvas){
    // background
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ), 
      Paint()..color = Colors.black
    );

    _drawPlayerHotSpots(canvas);
    _drawRoomDoors(canvas);
    _drawSummaryAreaMinimal(canvas);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ), 
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );
  }

  void _drawPlayerHotSpots(Canvas canvas){
    Paint circlePaint = Paint()
     ..color = Color.fromARGB(255, 255, 50, 50)
     ..style = PaintingStyle.stroke
     ..strokeWidth = width/150;

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
          ..strokeWidth = width/150
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


    // if the doors lead to a room, draw an extra circle on them
    Tuple2<int,int> getNewRoomPosition(Tuple2<int,int> currentRoomPos, int newIndex){
      Tuple2<int,int> newRoomPosition = switch (newIndex) {
        0 => Tuple2(currentRoomPos.item1+0, currentRoomPos.item2-1),
        1 => Tuple2(currentRoomPos.item1+1, currentRoomPos.item2+0),
        2 => Tuple2(currentRoomPos.item1+0, currentRoomPos.item2+1),
        3 => Tuple2(currentRoomPos.item1-1, currentRoomPos.item2+0),
        _ => Tuple2(0,0),
      };
      return newRoomPosition;
    }
    
    for (int i = 0; i <= 3; i++){
      Tuple2<int,int> newRoomPosition = getNewRoomPosition(roomsData[currentRoomIndex!].pos, i);
      if ((roomsData.map((roomData)=>roomData.pos)).contains(newRoomPosition)){
        Offset iconOffset = switch (i) {
          0 => Offset(0, -height/2),
          1 => Offset(width/2, 0),
          2 => Offset(0, height/2),
          3 => Offset(-width/2, 0),
          _ => Offset(0,0),
        };
        canvas.drawCircle(
          iconOffset, 
          doorSize/2, 
          doorPaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = width/100
        );
      }
    }
  }

  Tuple2<int, int> getNewRoomPosition(Tuple2<int, int> currentRoomPos, int newIndex){
    Tuple2<int, int> newRoomPosition = switch (newIndex) {
      0 => Tuple2(currentRoomPos.item1+0, currentRoomPos.item2-1),
      1 => Tuple2(currentRoomPos.item1+1, currentRoomPos.item2+0),
      2 => Tuple2(currentRoomPos.item1+0, currentRoomPos.item2+1),
      3 => Tuple2(currentRoomPos.item1-1, currentRoomPos.item2+0),
      _ => Tuple2(0,0),
    };
    return newRoomPosition;
  }

  void _drawSummaryArea(Canvas canvas){
    Size summarySize = Size(2*width/3, height);
    double squareSize = min(summarySize.width, summarySize.height);

    canvas.translate(1.05*width/2, -height/2);

    canvas.drawRect(
      Rect.fromLTWH(0,0, summarySize.width, summarySize.height), 
      Paint()..color = Colors.white
    );

    Paint roomPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Paint connectionPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = width / 200;

    Paint highlightPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = width / 100;

    GameRoomData currentRoomData = roomsData[currentRoomIndex!];
    Offset currentRoomOffset = Offset(
      currentRoomData.pos.item1 * summarySize.width / 5 + summarySize.width/2,
      currentRoomData.pos.item2 * summarySize.height / 5 + summarySize.height/2,
    );
    canvas.translate(-currentRoomOffset.dx + summarySize.width/2, -currentRoomOffset.dy + summarySize.height/2);
    for (var roomData in roomsData) {
      if (
        roomData.pos.item1 > currentRoomData.pos.item1+2 || 
        roomData.pos.item2 > currentRoomData.pos.item2+2 ||
        roomData.pos.item1 < currentRoomData.pos.item1-2 || 
        roomData.pos.item2 < currentRoomData.pos.item2-2 
      ){continue;}

      Offset roomOffset = Offset(
        roomData.pos.item1 * summarySize.width / 5 + summarySize.width/2,
        roomData.pos.item2 * summarySize.height / 5 + summarySize.height/2,
      );

      // Draw connections to adjacent rooms
      for (int i = 0; i <= 3; i++) {
        Tuple2<int, int> adjacentPos = getNewRoomPosition(roomData.pos, i);
        if (roomsData.any((room) => room.pos == adjacentPos)) {
          Offset adjacentOffset = Offset(
            adjacentPos.item1 * summarySize.width / 5 + summarySize.width/2,
            adjacentPos.item2 * summarySize.height / 5 + summarySize.height/2,
          );
          canvas.drawLine(roomOffset, adjacentOffset, connectionPaint);
        }
      }
    }

    for (var roomData in roomsData) {
      if (
        roomData.pos.item1 > currentRoomData.pos.item1+2 || 
        roomData.pos.item2 > currentRoomData.pos.item2+2 ||
        roomData.pos.item1 < currentRoomData.pos.item1-2 || 
        roomData.pos.item2 < currentRoomData.pos.item2-2 
      ){continue;}
      
      Offset roomOffset = Offset(
        roomData.pos.item1 * summarySize.width / 5 + summarySize.width/2,
        roomData.pos.item2 * summarySize.height / 5 + summarySize.height/2,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: roomOffset,
          width: squareSize / 10,
          height: squareSize / 10
        ),
        roomPaint,
      );
      if (roomData.pos == roomsData[currentRoomIndex!].pos) {
        canvas.drawCircle(
          roomOffset, 
          squareSize / 10, 
          highlightPaint
        );
      }
    }
    canvas.translate(currentRoomOffset.dx - summarySize.width/2, currentRoomOffset.dy - summarySize.height/2);

    canvas.drawRect(
      Rect.fromLTWH(0,0, 2*width/3, height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
        ..color = Colors.grey
    );

    
    canvas.translate(-1.05*width/2, height/2);
  }

  void _drawSummaryAreaMinimal(Canvas canvas){
    Size summarySize = Size(2*width/3, height);
    double squareSize = min(summarySize.width, summarySize.height);

    canvas.translate(1.05*width/2, -height/2);

    canvas.drawRect(
      Rect.fromLTWH(0,0, summarySize.width, summarySize.height), 
      Paint()..color = Colors.black
    );

    Paint roomPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Paint connectionPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = width / 200;

    Paint highlightPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = width / 100;

    GameRoomData currentRoomData = roomsData[currentRoomIndex!];
    Offset currentRoomOffset = Offset(
      currentRoomData.pos.item1 * summarySize.width / 5 + summarySize.width/2,
      currentRoomData.pos.item2 * summarySize.height / 5 + summarySize.height/2,
    );
    canvas.translate(-currentRoomOffset.dx + summarySize.width/2, -currentRoomOffset.dy + summarySize.height/2);
    for (var roomData in roomsData) {
      if (
        roomData.pos.item1 > currentRoomData.pos.item1+2 || 
        roomData.pos.item2 > currentRoomData.pos.item2+2 ||
        roomData.pos.item1 < currentRoomData.pos.item1-2 || 
        roomData.pos.item2 < currentRoomData.pos.item2-2 
      ){continue;}

      Offset roomOffset = Offset(
        roomData.pos.item1 * summarySize.width / 5 + summarySize.width/2,
        roomData.pos.item2 * summarySize.height / 5 + summarySize.height/2,
      );

      // Draw connections to adjacent rooms
      for (int i = 0; i <= 3; i++) {
        Tuple2<int, int> adjacentPos = getNewRoomPosition(roomData.pos, i);
        if (roomsData.any((room) => room.pos == adjacentPos)) {
          Offset adjacentOffset = Offset(
            adjacentPos.item1 * summarySize.width / 5 + summarySize.width/2,
            adjacentPos.item2 * summarySize.height / 5 + summarySize.height/2,
          );
          canvas.drawLine(roomOffset, (roomOffset+adjacentOffset)/2, connectionPaint);
        }
      }
    }

    for (var roomData in roomsData) {
      if (
        roomData.pos.item1 > currentRoomData.pos.item1+2 || 
        roomData.pos.item2 > currentRoomData.pos.item2+2 ||
        roomData.pos.item1 < currentRoomData.pos.item1-2 || 
        roomData.pos.item2 < currentRoomData.pos.item2-2 
      ){continue;}
      
      Offset roomOffset = Offset(
        roomData.pos.item1 * summarySize.width / 5 + summarySize.width/2,
        roomData.pos.item2 * summarySize.height / 5 + summarySize.height/2,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: roomOffset,
          width: squareSize / 10,
          height: squareSize / 10
        ),
        roomPaint,
      );
      if (roomData.pos == roomsData[currentRoomIndex!].pos) {
        canvas.drawCircle(
          roomOffset, 
          squareSize / 10, 
          highlightPaint
        );
      }
    }
    canvas.translate(currentRoomOffset.dx - summarySize.width/2, currentRoomOffset.dy - summarySize.height/2);

    canvas.drawRect(
      Rect.fromLTWH(0,0, 2*width/3, height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
        ..color = Colors.white
    );

    
    canvas.translate(-1.05*width/2, height/2);
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