import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:project57/components/minimap_component.dart';
import 'package:project57/components/table_component.dart';
import 'package:project57/datastructures/game_overall_data.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/components/item_component.dart';
import 'package:project57/datastructures/item_data.dart';

class MyFlameGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks  {
  MyItemComponent? currentlyDraggedComponent;

  double get width => size.x;
  double get height => size.y;
  GameOverallData gameData = GameOverallData();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    double squareSize = min(width,height);

    camera.viewfinder.anchor = Anchor.center;
    // shift the camera to the center of the screen
    // Set the camera to center on (0, 0)
    camera.viewfinder.position = Vector2(0,height/15);

    final background = RectangleComponent(
      size: Vector2(width, height), // width and height
      paint: Paint()..color = Colors.black, // color of the square
      position: Vector2(-width/2, -height/2), // position on the canvas
    );

    // setup the initial game data
    gameData.addInitialroom();

    final MyMinimapComponent minimap = MyMinimapComponent(
      gameData: gameData,
      moveToRoomIndex: gameData.moveCurrentRoomIndex,
      setCurrentRoomPositionindex: gameData.setCurrentRoomPositionindex,
      roomsData: gameData.rooms,
      currentRoomIndex: gameData.currentRoomIndex?.value,
      currentRoomPositionindex: gameData.currentRoomPositionindex?.value,
      size: Vector2(squareSize/2, squareSize/2),
      position: Vector2(0, height/4),
      showGridOverlay: true,
    );

    final MyTableComponent table1 = MyTableComponent(
      gameData: gameData,
      size: Vector2(3*squareSize/5,3*squareSize/5),
      position: Vector2(1.1*(-4*squareSize/10),-3*squareSize/60),
      tableIndex: gameData.currentRoomPositionindex!.value,
      relativeRotationIndex: 0,
      showGridOverlay: true
    );

    final MyTableComponent table2 = MyTableComponent(
      gameData: gameData,
      size: Vector2(3*squareSize/5,3*squareSize/5),
      position: Vector2(1.1*(4*squareSize/10),-3*squareSize/60),
      tableIndex: (gameData.currentRoomPositionindex!.value+1)%4,
      relativeRotationIndex: 1,
      showGridOverlay: true
    );

    world.add(background);
    world.add(minimap);
    world.add(table1);
    world.add(table2);

    // 🔁 Listen to changes and update table indices
    gameData.currentRoomPositionindex!.addListener(() {
      table1.updateTableIndex(gameData.currentRoomPositionindex!.value);
      table2.updateTableIndex((gameData.currentRoomPositionindex!.value + 1) % 4);
    });

    // make the camera follow something
    // camera.follow();

    // debugMode = true;
  }
}