import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';

class MyItemComponent extends RectangleComponent with DragCallbacks {
  bool _dragging = false;
  late Vector2 _basePosition;
  GameItem item;
  List<Offset> points = [];
  Offset baseOffset;

  MyItemComponent({
    required this.item,
    required this.points,
    required this.baseOffset,
    super.size,
    super.paint,
    super.position 
  }){
    _basePosition = position;
  }

  void _onItemDataChanged(){
    Offset positionOffset = Offset(0, 0);
    if (item.posOffset != Offset(0,0)){
      positionOffset = Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y);
    } else {
      positionOffset = baseOffset + Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y) + points[item.pos.item2 * (GameTable.cellCount-1) + item.pos.item1];
    }
    position = Vector2(positionOffset.dx,positionOffset.dy);
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    anchor = Anchor.center;

    // Listen to changes in table data
    item.addListener(_onItemDataChanged);
  }

  @override
  bool onDragStart(DragStartEvent event) {
    _dragging = true;
    return true; // returning true means we "claim" the drag
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragging) {
      // Follow the mouse by updating position relative to drag start
      position = position + event.canvasDelta;
      item.updateOffset(Offset(position.x/size.x, position.y/size.y));
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragging = false;
    if (item.parentTable != null){
      item.parentTable!.alignItemsToGrid();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragging = false;
  }
}