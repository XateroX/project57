import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class MyItemComponent extends RectangleComponent with DragCallbacks {
  bool _dragging = false;
  late Vector2 _basePosition;

  MyItemComponent({
    super.size,
    super.paint,
    super.position 
  }){
    _basePosition = position;
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
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragging = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragging = false;
  }
}