import 'dart:math';
import 'dart:ui';

import 'package:flame/post_process.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:project57/components/carry_tray_component.dart';
import 'package:project57/components/item_summary_component.dart';
import 'package:project57/components/minimap_component.dart';
import 'package:project57/components/table_component.dart';
import 'package:project57/datastructures/game_overall_data.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/components/item_component.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/shaders/shadow_and_candle.dart';

class MyFlameGame extends FlameGame 
  with HasKeyboardHandlerComponents, TapCallbacks, HasCollisionDetection, MouseMovementDetector  {
  double currentT = 0.0;
  double lastT = 0.0;

  MyItemComponent? currentlyDraggedComponent;
  MyTableComponent? currentlyTargetedTableComponent;
  late CarryTrayComponent carryTray;
  ValueNotifier<GameItem?> detailViewingItem = ValueNotifier(null);

  double get width => size.x;
  double get height => size.y;
  late double squareSize;
  GameOverallData gameData = GameOverallData();

  ValueNotifier<List<Vector2>> listOfCandlePositions = ValueNotifier([]);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    squareSize = min(width,height);
    carryTray = CarryTrayComponent(
      tray: gameData.carryTray,
      position: Vector2(0, 0.5* (-3*squareSize/8) - 10),
      size: Vector2(squareSize/4,3*squareSize/8),
    );

    camera.viewfinder.anchor = Anchor.center;
    // shift the camera to the center of the screen
    // Set the camera to center on (0, 0)
    camera.viewfinder.position = Vector2(0,height/15);
    currentPosition.value = camera.viewfinder.position;

    final background = SpriteComponent(
      size: Vector2(width*1.1, height*1.1), // width and height
      paint: Paint()..color = Colors.black, // color of the square
      position: Vector2(-width/2, -height/2), // position on the canvas
      sprite: await Sprite.load("textures/cobblestone.jpeg"),
    );

    // setup the initial game data
    gameData.addInitialroom();

    gameData.createDungeonLayout(20);

    final MyMinimapComponent minimap = MyMinimapComponent(
      gameData: gameData,
      moveToRoomIndex: gameData.moveCurrentRoomIndex,
      setCurrentRoomPositionindex: gameData.setCurrentRoomPositionindex,
      roomsData: gameData.rooms,
      currentRoomIndex: gameData.currentRoomIndex,
      currentRoomPositionindex: gameData.currentRoomPositionindex,
      size: Vector2(squareSize/2, squareSize/2),
      position: Vector2(-width/10, height/4),
      showGridOverlay: false,
    );

    final MyTableComponent table1 = MyTableComponent(
      gameData: gameData,
      size: Vector2(3*squareSize/5,3*squareSize/5),
      position: Vector2(1.1*(-4*squareSize/10),-3*squareSize/60),
      tableIndex: gameData.currentRoomPositionindex,
      relativeRotationIndex: 0,
      showGridOverlay: false
    );

    final MyTableComponent table2 = MyTableComponent(
      gameData: gameData,
      size: Vector2(3*squareSize/5,3*squareSize/5),
      position: Vector2(1.1*(4*squareSize/10),-3*squareSize/60),
      tableIndex: (gameData.currentRoomPositionindex+1)%4,
      relativeRotationIndex: 1,
      showGridOverlay: false
    );

    final MyItemSummaryComponent itemSummary = MyItemSummaryComponent(
      size: Vector2(
        (width/2) *0.9, 
        height *0.9
      ),
      position: Vector2(
        width/4,
        height/2,
      )
    ); 

    listOfCandlePositions.value.add(Vector2(width/5,height/3));
    listOfCandlePositions.value.add(Vector2(width - width/5,height/3));

    // world.add(background);
    world.add(minimap);
    world.add(carryTray);
    world.add(table1);
    world.add(table2);
    world.add(itemSummary);

    // Listen to changes and update table indices
    gameData.addListener(() {
      table1.updateTableIndex(gameData.currentRoomPositionindex);
      table2.updateTableIndex((gameData.currentRoomPositionindex + 1) % 4);
    });
    gameData.addListener(() {
      table1.updateTableIndex(gameData.currentRoomPositionindex);
      table2.updateTableIndex((gameData.currentRoomPositionindex + 1) % 4);
    });

    // camera.postProcess = PostProcessGroup(
    //   postProcesses: [
    //     PostProcessSequentialGroup(
    //       postProcesses: [
    //         ShadowAndCandlePostProcess(
    //           mousePos:mousePos,
    //           extraCandleLocations:listOfCandlePositions,
    //         ),
    //       ],
    //     ),
    //   ],
    // );

    gameData.startGameTicks();
  } 

  ValueNotifier<Vector2?> targetPosition = ValueNotifier(null);
  ValueNotifier<Vector2?> currentPosition = ValueNotifier(null);
  double? targetZoom;
  double zoomLerpSpeed = 4.0;
  double lerpSpeed = 4.0;

  @override
  void update(double dt) {
    super.update(dt);
    currentT += dt;

    if (targetPosition.value != null) {
      camera.viewfinder.position = Vector2(
        camera.viewfinder.position.x + (targetPosition.value!.x - camera.viewfinder.position.x) * lerpSpeed * dt,
        camera.viewfinder.position.y + (targetPosition.value!.y - camera.viewfinder.position.y) * lerpSpeed * dt,
      );
      currentPosition.value = camera.viewfinder.position;
    } else {
      targetPosition.value = Vector2(0,height/15);
    }

    if (targetZoom != null) {
      camera.viewfinder.zoom = camera.viewfinder.zoom + (targetZoom! - camera.viewfinder.zoom) * zoomLerpSpeed * dt;
    } else {
      targetZoom = 1.0;
    }

    if (currentT - lastT > 1.0){
      _checkMachinesForInputs();
      lastT = currentT;
    }
  }

  void _checkMachinesForInputs(){
    for (GameRoomData roomData in gameData.rooms) {
      for (GameTable tableData in roomData.tables) {
        List<GameItem> tempChildItems = List.from(tableData.childItems);
        for (GameItem item in tempChildItems) {
          if (item.isMachine && item.processing.length < GameItem.MAX_PROCESSING) {
            item.processInputItems();
          }
        }
      }
    }
  }

  @override
  void render(Canvas canvas){
    super.render(canvas);
    canvas.drawCircle(mousePos.value.toOffset(), 5, Paint()..color = const Color(0xFFFF0000));
  }

  @override

  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    if (event.logicalKey == LogicalKeyboardKey.space) {
      targetZoom = 1.0;
      targetPosition.value = Vector2(0,height/15);
      detailViewingItem.value = null;
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  ValueNotifier<Vector2> mousePos = ValueNotifier(Vector2(500,500));

  @override
  void onMouseMove(PointerHoverInfo info) {
    // info.eventPosition.global is the Vector2 relative to the game viewport
    mousePos.value = info.eventPosition.global;
    super.onMouseMove(info);
  }
}
