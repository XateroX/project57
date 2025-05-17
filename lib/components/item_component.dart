import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project57/components/carry_tray_component.dart';
import 'package:project57/components/table_component.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/game.dart';
import 'package:project57/utils/geometry.dart';
import 'package:tuple/tuple.dart';

class MyItemComponent extends PositionComponent with DragCallbacks, KeyboardHandler, HasGameReference<MyFlameGame>, CollisionCallbacks {
  bool _dragging = false;
  late Vector2 _basePosition;
  GameItem item;
  List<Offset>? points = [];
  Offset baseOffset;
  int relativeRotationIndex;
  MyTableComponent? parentTableComp;
  CarryTrayComponent? parentTray;
  bool minifiedMode = false;

  double ghostOpacity = 0.0;

  double machineProgressRatio = 0.0;

  MyItemComponent({
    required this.item,
    this.points,
    required this.baseOffset,
    required this.relativeRotationIndex,
    this.parentTableComp,
    this.parentTray,
    this.minifiedMode = false,
    super.size,
    super.position,
  }){
    _basePosition = position;
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    
    anchor = Anchor.center;

    add(RectangleHitbox(
      size: Vector2(width, height),
      isSolid: true,
    ));

    // Listen to changes in table data
    item.addListener(_onItemDataChanged);

    machineProgressRatio = item.processingRatio;
    if (!item.currentlyProcessing){
      machineProgressRatio = 0.0;
    }
  }

  @override
  void onRemove() {
    item.removeListener(_onItemDataChanged);
    super.onRemove();
  }

  void _onItemDataChanged(){
    Offset positionOffset = Offset(0, 0);

    if (parentTableComp != null){
      if (item.posOffset != Offset(0,0)){
        positionOffset = Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y);
      } else {
        positionOffset = baseOffset + Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y) + points![itemPointsIndex()];
      }
    } else if (parentTray != null){
      if (item.posOffset != Offset(0,0)){
        positionOffset = Offset(item.posOffset.dx*size.x, item.posOffset.dy*size.y);
      } else {
        int index = parentTray!.tray.items.indexOf(item);
        int row = index ~/ 3;
        int totalItems = parentTray!.tray.items.length;
        Vector2 pos = CarryTrayComponent.itemPositionByIndex(index, row, totalItems);
        positionOffset = Offset(pos.x*parentTray!.width, pos.y*parentTray!.height);
      }
    }

    position = Vector2(positionOffset.dx,positionOffset.dy);
  }

  int itemPointsIndex(){
    return item.pos.item2 * (GameTable.cellCount-1) + item.pos.item1;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (item.posOffset == Offset(0,0)){
      ghostOpacity = 0.0;
    } else {
      ghostOpacity = ghostOpacity + (1.0 - ghostOpacity) * 3.0 * dt;
    }

    if (item.isMachine){
      if (item.currentlyProcessing){
        if (machineProgressRatio < 1.0){
          machineProgressRatio += dt/item.processingDuration;
          if (machineProgressRatio > 1.0){
            machineProgressRatio = 1.0;
          }
        }
      } else {
        machineProgressRatio = 0.0;
      }
      item.processingRatio = machineProgressRatio;
    }
  }

  @override
  void render(Canvas canvas){
    canvas.translate(width/2, height/2);

    // _renderStyleDebug(canvas);
    _renderStyleMinimal(canvas);

    _drawGhostItem(canvas);

    canvas.translate(-width/2, -height/2);
  }

  void _drawGhostItem(Canvas canvas){
    if (item.posOffset == Offset(0,0)){return;}
    if (item.parentTable == null){return;}
    Offset ghostOffset = baseOffset + points![itemPointsIndex()] - position.toOffset();

    // Paint paint = Paint()
    //   ..color=Colors.white.withAlpha(30)
    //   ..style=PaintingStyle.stroke
    //   ..strokeWidth=width/30;
    Paint fillPaint = Paint()
      ..color = Color.fromARGB((30*ghostOpacity).toInt(), 141, 141, 141)
      ..style=PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: ghostOffset, 
        width: width, 
        height: height
      ),
      fillPaint
    );
    // canvas.drawRect(
    //   Rect.fromCenter(
    //     center: ghostOffset, 
    //     width: width, 
    //     height: height
    //   ),
    //   paint
    // );
  }

  void _renderStyleDebug(Canvas canvas){
    // draw the basic shape and name 
    _drawBasicShapeAndName(canvas);

    // draw anything indicating what processing has been done
    _drawProcessedEffects(canvas);

    // if machine, handle all machine drawing
    _drawMachineDetails(canvas);
  }

  void _renderStyleMinimal(Canvas canvas){
    // draw the basic shape and name 
    _drawBasicShapeAndNameMinimal(canvas);

    // draw anything indicating what processing has been done
    _drawProcessedEffectsMinimal(canvas);

    canvas.translate(0, -height/5.5); // No idea why i need this to line things up XD

    // if machine, handle all machine drawing
    _drawMachineDetailsMinimal(canvas);
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

    // processing limit //
    if (item.processing.length >= GameItem.MAX_PROCESSING){
      Paint paint = Paint()
        ..color=Colors.red.withAlpha(100)
        ..style=PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(0,0), 
          width: width, 
          height: height
        ),
        paint
      );
    }
    // //

    if (minifiedMode){return;}
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

    if (
      !(
        itemPointsIndex()+inputOffsetIndex >= 0 && 
        itemPointsIndex()+inputOffsetIndex < GameTable.cellCount*GameTable.cellCount && 
        itemPointsIndex()+outputOffsetIndex >= 0 && 
        itemPointsIndex()+outputOffsetIndex < GameTable.cellCount*GameTable.cellCount
      )
      || 
      (
        parentTray != null
      )
    ) return;

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
    if (minifiedMode){return;}

    canvas.translate(-width/2, -height/2);
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

  void _drawBasicShapeAndNameMinimal(Canvas canvas){
    Paint paint = Paint()
      ..color=Colors.white
      ..style=PaintingStyle.stroke
      ..strokeWidth=width/30;
    Paint fillPaint = Paint()
      ..color=Colors.black
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

    // processing limit //
    if (item.processing.length >= GameItem.MAX_PROCESSING){
      Paint paint = Paint()
        ..color=Colors.red.withAlpha(50)
        ..style=PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(0,0), 
          width: width, 
          height: height
        ),
        paint
      );
    }
    // //

    if (minifiedMode){return;}
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: item.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: ((4/item.name.length).clamp(0.4, 1))*width/3,
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

  void _drawMachineDetailsMinimal(Canvas canvas){
    // check if the input and output offsets are valid
    int inputOffsetIndex = item.inputOffset.item2 * (GameTable.cellCount-1) + item.inputOffset.item1;
    int outputOffsetIndex = item.outputOffset.item2 * (GameTable.cellCount-1) + item.outputOffset.item1;

    if (
      !(
        itemPointsIndex()+inputOffsetIndex >= 0 && 
        itemPointsIndex()+inputOffsetIndex < GameTable.cellCount*GameTable.cellCount && 
        itemPointsIndex()+outputOffsetIndex >= 0 && 
        itemPointsIndex()+outputOffsetIndex < GameTable.cellCount*GameTable.cellCount
      )
      || 
      (
        parentTray != null
      )
    ) return;

    Offset inputOffset = Offset(width*item.inputOffset.item1,height*item.inputOffset.item2);
    Offset outputOffset = Offset(width*item.outputOffset.item1,height*item.outputOffset.item2);

    inputOffset = relativeRotationOffset(inputOffset, (item.relativeRotationIndex+relativeRotationIndex)%4);
    outputOffset = relativeRotationOffset(outputOffset, (item.relativeRotationIndex+relativeRotationIndex)%4);

    if (item.isMachine){
      Paint paint = Paint()
        ..color=Colors.white.withAlpha(100)
        ..style=PaintingStyle.fill;
      Paint inAreaPaint = Paint()
        ..color=Color.fromARGB(100, 199, 253, 168)
        ..style=PaintingStyle.stroke
        ..strokeWidth=width/10;
      Paint outAreaPaint = Paint()
        ..color=Color.fromARGB(100, 168, 247, 253)
        ..style=PaintingStyle.stroke
        ..strokeWidth=width/10;

      canvas.drawCircle(
        inputOffset,
        width/6,
        inAreaPaint
      );

      canvas.drawCircle(
        outputOffset,
        width/6,
        outAreaPaint
      );

      canvas.drawRect(
        Rect.fromLTWH(-width/2,-height/2, width*(machineProgressRatio), height), 
        paint
      );

      // canvas.drawCircle(inputOffset.scale(0.7, 0.7), width/15, paint);
      // canvas.drawCircle(outputOffset.scale(0.7, 0.7), width/15, paint);
      // canvas.drawLine(
      //   inputOffset.scale(0.7, 0.7),
      //   outputOffset.scale(0.7, 0.7),
      //   paint
      // );
    }
  }

  void _drawProcessedEffectsMinimal(Canvas canvas){
    if (minifiedMode){return;}

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

  // DRAGGING //
  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragging = true;
    (findGame() as MyFlameGame).currentlyDraggedComponent = this;
    if (parent is MyTableComponent){
      (findGame() as MyFlameGame).currentlyTargetedTableComponent = parent as MyTableComponent;
      //  print("${(parent as MyTableComponent).table.id}  ${relativeRotationIndex}");
      (parent as MyTableComponent).setIsBeingHovered(true);
      print("\n ${(findGame() as MyFlameGame).currentlyDraggedComponent==null} \n ${(findGame() as MyFlameGame).currentlyTargetedTableComponent==null} \n ${(findGame() as MyFlameGame).currentlyDraggedComponent==null}");
    }
    // Notify game this is the active one
    
    return true; // returning true means we "claim" the drag
  }

  @override

  void onDragUpdate(DragUpdateEvent event) {
    if (_dragging) {
      // Follow the mouse by updating position relative to drag start
      position = position + event.localDelta;
      item.updateOffset(Offset(position.x/size.x, position.y/size.y));
      // (findGame() as MyFlameGame).currentlyDraggedComponent = this;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    centerCameraAfterMove();
    if (_dragging){
      if (
        (findGame() as MyFlameGame).currentlyTargetedTableComponent != null &&
        item.parentTable != (findGame() as MyFlameGame).currentlyTargetedTableComponent!.table
      ){
        MyTableComponent newTable = (findGame() as MyFlameGame).currentlyTargetedTableComponent!;

        Vector2 oldPosition = parentTableComp != null 
          ? parentTableComp!.position 
          : parentTray != null 
            ? parentTray!.position + Vector2(parentTray!.width/2, parentTray!.height/2)
            : Vector2(0,0);

        Vector2 newTableBaseOffset = newTable.position - oldPosition;

        // set the posOffset to be relative to the new table origin
        item.updateOffset(
          Offset(
            (position.x-newTableBaseOffset.x)/size.x, 
            (position.y-newTableBaseOffset.y)/size.y
          )
        );

        if (parent is MyTableComponent){
          (parent as MyTableComponent).setIsBeingHovered(false);
          item.parentTable!.removeItem(item);
        } else if (parent is CarryTrayComponent){
          (parent as CarryTrayComponent).setIsBeingHovered(false);
          parentTray!.tray.removeItem(item);
        }
        item.parentTable = newTable.table;
        item.parentTable!.addItem(item);
        parent!.children.remove(this);
        item.parentTable!.handleItemsPlaced([item], newTable.relativeRotationIndex);
        newTable.setIsBeingHovered(false);
        relaxCamera();
      }
      else if (
        (findGame() as MyFlameGame).carryTray.isBeingHovered &&
        (findGame() as MyFlameGame).carryTray.tray.items.length < 9
      ){
        relaxCamera();
        (findGame() as MyFlameGame).carryTray.setIsBeingHovered(false);
        item.parentTable!.removeItem(item);
        item.parentTable = null;
        parent!.children.remove(this);
        (findGame() as MyFlameGame).carryTray.tray.addItem(item);
      }
      else if (item.parentTable != null){
        item.parentTable!.handleItemsPlaced([item], relativeRotationIndex);
        if (parent is MyTableComponent){
          (parent as MyTableComponent).setIsBeingHovered(false);
          (findGame() as MyFlameGame).currentlyTargetedTableComponent = null;
        }
        (findGame() as MyFlameGame).carryTray.setIsBeingHovered(false);
      } else if (parentTray != null){
        item.setPosOffset(Offset(0,0));
      }
    }
    (findGame() as MyFlameGame).currentlyDraggedComponent = null;
    (findGame() as MyFlameGame).currentlyTargetedTableComponent = null;
    _dragging = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _dragging = false;
    (findGame() as MyFlameGame).currentlyDraggedComponent = null;
    (findGame() as MyFlameGame).currentlyTargetedTableComponent = null;
  }
  // //


  // COLLISION //
  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    print("COLLISION START");
    if (
      game.currentlyDraggedComponent==null || 
      (
        game.currentlyDraggedComponent!=null && 
        game.currentlyDraggedComponent! != this
      )
    ) {
      return;
    }
    if (other is MyTableComponent) {
      if (other.minifiedMode){return;}
      // print("Its working, it's working!!");
      if (!other.isBeingHovered){
        (findGame() as MyFlameGame).currentlyTargetedTableComponent = other;
        other.setIsBeingHovered(true);
      }
      other.setIsBeingHovered(true);
    } else if (other is CarryTrayComponent) {
      other.setIsBeingHovered(true);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    print("COLLISION END");
    if (
      game.currentlyDraggedComponent==null || 
      (
        game.currentlyDraggedComponent!=null && 
        game.currentlyDraggedComponent! != this
      )
    ) {
      return;
    }
    if (other is MyTableComponent) {
      if (other.minifiedMode){return;}
      other.setIsBeingHovered(false);
      if ((findGame() as MyFlameGame).currentlyTargetedTableComponent == other){
        (findGame() as MyFlameGame).currentlyTargetedTableComponent = null;
      }
    } else if (other is CarryTrayComponent) {
      other.setIsBeingHovered(false);
    }
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

        if (
          event.logicalKey == LogicalKeyboardKey.shiftLeft &&
          (findGame() as MyFlameGame).carryTray.tray.items.length < 9
        ) {
          (findGame() as MyFlameGame).carryTray.setIsBeingHovered(false);
          item.parentTable!.removeItem(item);
          item.parentTable = null;
          parent!.children.remove(this);
          (findGame() as MyFlameGame).carryTray.tray.addItem(item);
          _dragging = false;
          return false;
        }

        if (
          event.logicalKey == LogicalKeyboardKey.digit1 || 
          event.logicalKey == LogicalKeyboardKey.digit2
        ){
          MyTableComponent? newTable;
          if (
            event.logicalKey == LogicalKeyboardKey.digit1 &&
            parentTray != null
          ) {
            newTable = (findGame() as MyFlameGame).world.children.where((x) => (x is MyTableComponent)&&(x.relativeRotationIndex==0)).firstOrNull as MyTableComponent?;
          }
          if (
            event.logicalKey == LogicalKeyboardKey.digit2 &&
            parentTray != null
          ) {
            newTable = (findGame() as MyFlameGame).world.children.where((x) => (x is MyTableComponent)&&(x.relativeRotationIndex==1)).firstOrNull as MyTableComponent?;
          }

          (parent as CarryTrayComponent).setIsBeingHovered(false);
          parentTray!.tray.removeItem(item);
          
          if (newTable == null) return false;
          item.parentTable = newTable.table;
          Tuple2<int,int>? newHome = item.parentTable!.findHome();
          if (newHome == null){return false;}
          item.pos = newHome;
          item.posOffset = Offset(0,0);
          item.parentTable!.addItem(item);
          parent!.children.remove(this);
          // item.parentTable!.handleItemsPlaced([item], newTable.relativeRotationIndex);
          newTable.setIsBeingHovered(false);
          _dragging = false;
          return false;
        }
      }
      return true;
    // } else {
    //   return false;
    // }
  }

  void relaxCamera(){
    (findGame() as MyFlameGame).targetPosition = null;
    (findGame() as MyFlameGame).targetZoom = null;
  }

  void centerCameraAfterMove(){
    if (parentTableComp != null){
      (findGame() as MyFlameGame).targetPosition = parentTableComp!.absoluteCenter;
      (findGame() as MyFlameGame).targetZoom = 1.2;
    } else {
      (findGame() as MyFlameGame).targetPosition = parentTray!.absoluteCenter;
      (findGame() as MyFlameGame).targetZoom = 1.5;
    }
  }
}