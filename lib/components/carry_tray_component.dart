import 'dart:ffi';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/components/item_component.dart';
import 'package:project57/datastructures/carry_tray_data.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/game.dart';

class CarryTrayComponent extends PositionComponent with HasGameReference<MyFlameGame> {
  bool isBeingHovered=false;
  GameCarryTray tray;

  CarryTrayComponent({
    required this.tray,
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size
  );

  void _onTrayDataChanged(){
    removeAll(children);
    addChildrenItemComponents();
  }

  @override
  Future<void> onLoad() async { 
    super.onLoad();
    // debugMode=true;
    anchor = Anchor.center;
    tray.addListener(_onTrayDataChanged);
    addChildrenItemComponents();
  }

  void setIsBeingHovered(bool hovering){
    isBeingHovered = hovering;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // _renderStyleDebug(canvas);
    _renderStyleMinimal(canvas);
  }

  void _renderStyleDebug(Canvas canvas){
    canvas.drawRect(
      Rect.fromLTRB(0, 0, width, height),
      Paint()..color = Colors.white    
    );
    canvas.drawRect(
      Rect.fromLTRB(0, 0, width, height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/50
        ..color = isBeingHovered ? Colors.green : Colors.grey  
    );
  }

  void _renderStyleMinimal(Canvas canvas){
    canvas.drawRect(
      Rect.fromLTRB(0, 0, width, height),
      Paint()..color = Colors.black    
    );
    canvas.drawRect(
      Rect.fromLTRB(0, 0, width, height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/50
        ..color = isBeingHovered ? Colors.green : Colors.white  
    );
  }

  void addChildrenItemComponents(){
    add(RectangleHitbox(
      size: Vector2(width, height),
      isSolid: true
    ));
    List<GameItem> items = List.from(tray.items);
    int divisions = 1;
    int row = 0;
    for (int i = 0; i < items.length; i++) {
      if (i % 3 == 0 && i != 0) row++;
      Vector2 position = itemPositionByIndex(i, row, items.length);

      double squareSize = (findGame() as MyFlameGame).squareSize;

      MyItemComponent itemComponent = MyItemComponent(
        item: items[i],
        points: [],
        size: Vector2((3*squareSize/5) / GameTable.cellCount, (3*squareSize/5) / GameTable.cellCount),
        relativeRotationIndex: 0,
        position: Vector2(position.x * width, position.y * height),
        baseOffset: Offset(width / 2, height / 2),
        parentTableComp: null,
        parentTray: this,
      );
      add(itemComponent);
    }
  }

  static Vector2 itemPositionByIndex(int index, int row, int totalItems){
    double x = ((index % 3 + 1) / 4);
    double y = ((row + 1) / (1 + (totalItems / 3).ceil()));
    return Vector2(x, y);
  }
}