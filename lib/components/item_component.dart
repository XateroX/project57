import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/game.dart';
import 'package:project57/utils/geometry.dart';

class MyItemComponent extends PositionComponent with DragCallbacks, KeyboardHandler {
  bool _dragging = false;
  late Vector2 _basePosition;
  GameItem item;
  List<Offset> points = [];
  Offset baseOffset;
  int relativeRotationIndex;

  MyItemComponent({
    required this.item,
    required this.points,
    required this.baseOffset,
    required this.relativeRotationIndex,
    super.size,
    super.position 
  }){
    _basePosition = position;
  }

  int itemPointsIndex(){
    return item.pos.item2 * (GameTable.cellCount-1) + item.pos.item1;
  }

  @override
  void render(Canvas canvas){
    canvas.translate(width/2, height/2);

    // if machine, handle all machine drawing
    _drawMachineDetails(canvas);

    // draw the basic shape and name 
    _drawBasicShapeAndName(canvas);

    // draw anything indicating what processing has been done
    _drawProcessedEffects(canvas);
  }

  void _drawBasicShapeAndName(Canvas canvas){
    Paint paint = Paint()
      ..color=Colors.blueGrey
      ..style=PaintingStyle.stroke
      ..strokeWidth=width/10;
    Paint fillPaint = Paint()
      ..color=Colors.grey
      ..style=PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ),
      fillPaint
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ),
      paint
    );
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: item.name,
        style: TextStyle(
          color: Colors.black,
          fontSize: (5/item.name.length)*width/3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width/2, -textPainter.height/2),
    );
  }

  void _drawMachineDetails(Canvas canvas){
    // check if the input and output offsets are valid
    int inputOffsetIndex = item.inputOffset.item2 * (GameTable.cellCount-1) + item.inputOffset.item1;
    int outputOffsetIndex = item.outputOffset.item2 * (GameTable.cellCount-1) + item.outputOffset.item1;

    if (!(
      itemPointsIndex()+inputOffsetIndex >= 0 && 
      itemPointsIndex()+inputOffsetIndex < points.length && 
      itemPointsIndex()+outputOffsetIndex >= 0 && 
      itemPointsIndex()+outputOffsetIndex < points.length
    )) return;

    Offset inputOffset = Offset(width*item.inputOffset.item1,height*item.inputOffset.item2);
    Offset outputOffset = Offset(width*item.outputOffset.item1,height*item.outputOffset.item2);

    inputOffset = relativeRotationOffset(inputOffset, (item.relativeRotationIndex+relativeRotationIndex)%4);
    outputOffset = relativeRotationOffset(outputOffset, (item.relativeRotationIndex+relativeRotationIndex)%4);

    if (item.isMachine){
      Paint paint = Paint()
        ..color=Colors.green
        ..style=PaintingStyle.fill
        ..strokeWidth=width/10;


      Paint inAreaPaint = Paint()
        ..color=Color.fromARGB(150, 199, 253, 168)
        ..style=PaintingStyle.fill;
      Paint outAreaPaint = Paint()
        ..color=Color.fromARGB(149, 168, 247, 253)
        ..style=PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: inputOffset, 
          width: width, 
          height: height
        ),
        inAreaPaint
      );

      canvas.drawRect(
        Rect.fromCenter(
          center: outputOffset, 
          width: width, 
          height: height
        ),
        outAreaPaint
      );

      canvas.drawCircle(inputOffset.scale(0.7, 0.7), width/15, paint);
      canvas.drawCircle(outputOffset.scale(0.7, 0.7), width/15, paint);
      canvas.drawLine(
        inputOffset.scale(0.7, 0.7),
        outputOffset.scale(0.7, 0.7),
        paint
      );
    }
  }

  void _drawProcessedEffects(Canvas canvas){
    canvas.translate(-width/2, -height/3);
    if (item.processing.isNotEmpty){
      int n = 1;
      for (ProcessingType process in item.processing){
        Paint paint = Paint()
          ..color=process.color
          ..style=PaintingStyle.fill;
        Paint outline = Paint()
          ..color=Colors.black//process.color
          ..style=PaintingStyle.stroke
          ..strokeWidth=width/50;
        canvas.drawCircle(
          Offset(
            width*(n/(1+item.processing.length)), 
            0
          ),
          width/(10+ item.processing.length),
          paint
        );
        canvas.drawCircle(
          Offset(
            width*(n/(1+item.processing.length)), 
            0
          ),
          width/(10+ item.processing.length),
          outline
        );
        n++;
      }
    }
    canvas.translate(width/2, height/2);
  }

  void _onItemDataChanged(){
    Offset positionOffset = Offset(0, 0);
    if (item.posOffset != Offset(0,0)){
      positionOffset = Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y);
    } else {
      positionOffset = baseOffset + Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y) + points[itemPointsIndex()];
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

  // DRAGGING //
  @override
  bool onDragStart(DragStartEvent event) {
    _dragging = true;
    // Notify game this is the active one
    // (findGame() as MyFlameGame).currentlyDraggedComponent = this;
    return true; // returning true means we "claim" the drag
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragging) {
      // Follow the mouse by updating position relative to drag start
      position = position + event.canvasDelta;
      item.updateOffset(Offset(position.x/size.x, position.y/size.y));
      (findGame() as MyFlameGame).currentlyDraggedComponent = this;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragging = false;
    if (item.parentTable != null){
      item.parentTable!.handleItemsPlaced([item], relativeRotationIndex);
    }
    (findGame() as MyFlameGame).currentlyDraggedComponent = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragging = false;
    (findGame() as MyFlameGame).currentlyDraggedComponent = null;
  }
  // //

  // KEYBOARD //
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final game = findGame() as MyFlameGame;
    if (
      game.currentlyDraggedComponent==null || 
      (
        game.currentlyDraggedComponent!=null && 
        game.currentlyDraggedComponent!.item.id != item.id
      )
    ) {
      return true;
    }

    // if (_dragging){
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.keyR) {
          item.relativeRotationIndex = (item.relativeRotationIndex + 1) % 4;
          print(item.relativeRotationIndex);
          return false;
        }
      }
      return true;
    // } else {
    //   return false;
    // }
  }
}