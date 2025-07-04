import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/game_overall_data.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:project57/components/item_component.dart';
import 'package:tuple/tuple.dart';

class MyTableComponent extends PositionComponent with CollisionCallbacks {
  late GameTable table;
  GameOverallData gameData;
  int tableIndex;
  int relativeRotationIndex;
  bool debug;
  bool showGridOverlay;
  bool isBeingHovered=false;
  bool minifiedMode=false;

  // basic drawing info
  late Path path;
  late List<Offset> points;

  MyTableComponent({
    required super.size,
    required super.position,
    required this.gameData,
    required this.tableIndex,
    required this.relativeRotationIndex,
    this.debug = false,
    this.showGridOverlay = false,
    this.minifiedMode = false,
  }){
    table = gameData.rooms[gameData.currentRoomIndex].tables[tableIndex];

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
    addChildrenItemComponents(table.childItems);
    add(RectangleHitbox(
      size: Vector2(width, height),
      isSolid: true
      )..collisionType);
    table.addListener(_onTableValuesChanged);
    gameData.addListener(_onGameDataChanged);
  }

  @override
  void onRemove() {
    table.removeListener(_onTableValuesChanged);
    gameData.removeListener(_onGameDataChanged);
    super.onRemove();
  }

  void setIsBeingHovered(bool hovering){
    isBeingHovered = hovering;
  }

  void updateTableIndex(int newIndex){
    tableIndex = newIndex;
    table.removeListener(_onTableValuesChanged);
    table = gameData.rooms[gameData.currentRoomIndex].tables[tableIndex];
    table.addListener(_onTableValuesChanged);
    removeAll(children);
    addChildrenItemComponents(table.childItems);
    add(
      RectangleHitbox(
        size: Vector2(width, height),
        isSolid: true
      )..collisionType
    );
  }

  void _onTableValuesChanged(){
    List<GameItem> childrenItemsToAdd = [];
    for (MyItemComponent item in children.whereType<MyItemComponent>()){
      if (!table.childItems.map((e) => e.id).contains(item.item.id)){
        remove(item);
      }
    }
    for (GameItem item in table.childItems){
      if (!children.whereType<MyItemComponent>().map((e) => e.item.id).contains(item.id)){
        childrenItemsToAdd.add(item);
      }
    }
    addChildrenItemComponents(childrenItemsToAdd);
  }

  void _onGameDataChanged(){
    if (
      gameData.rooms[gameData.currentRoomIndex].tables[tableIndex].id != table.id
    ){
      table = gameData.rooms[gameData.currentRoomIndex].tables[tableIndex];
      removeAll(children);
      addChildrenItemComponents(table.childItems);
      add(RectangleHitbox(
        size: Vector2(width, height),
        isSolid: true
      )..collisionType);
    }
  }

  @override

  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is MyItemComponent){
      other.onCollisionStart(points, this);
    }
  }


  void addChildrenItemComponents(List<GameItem> childrenItems){
    for (GameItem item in childrenItems){
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
        baseOffset: Offset(width/2,height/2),
        parentTableComp: this,
        minifiedMode: minifiedMode,
      );
      add(itemComponent);
    }
  }


  void _drawShadow(Canvas canvas){
    // draw shadow //
    canvas.translate(-width/2, -height/2);
    canvas.scale(1.1, 1.1);
    canvas.translate((1/1.05)*width/2, (1/1.05)*height/2);
    canvas.drawPath(
      path, 
      Paint()
        ..color = Colors.black.withAlpha(200)
    );
    canvas.translate(-(1/1.05)*width/2, -(1/1.05)*height/2);
    canvas.scale(1/1.1, 1/1.1);
    canvas.translate(width/2, height/2);
    // //
  }

  @override
  void render(Canvas canvas){
    super.render(canvas);

    canvas.translate(width/2, height/2);

    // _renderStyleDebug(canvas);
    _renderStyleMinimal(canvas);

    _renderGlobal(canvas);

    canvas.translate(-width/2, -height/2);
  }

  void _renderGlobal(Canvas canvas){
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
  }

  void _renderStyleDebug(Canvas canvas){
    // _drawShadow(canvas);

    canvas.drawPath(
      path, 
      Paint()
        ..color = Colors.white
    );

    canvas.drawPath(
      path, Paint()
        ..color = isBeingHovered ? Colors.green : Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );
  }

  void _renderStyleMinimal(Canvas canvas){
    canvas.drawPath(
      path, 
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black
    );

    canvas.drawPath(
      path, Paint()
        ..color = isBeingHovered ? Colors.green : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );
  }
}