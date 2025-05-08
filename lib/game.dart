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

class MyFlameGame extends FlameGame with KeyboardEvents {
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
      roomsData: gameData.rooms,
      currentRoomIndex: gameData.currentRoomIndex,
      currentRoomPositionindex: gameData.currentRoomPositionindex,
      size: Vector2(squareSize/2, squareSize/2),
      position: Vector2(0, height/4),
      showGridOverlay: true,
      debug: true
    );

    final MyTableComponent table1 = MyTableComponent(
      size: Vector2(3*squareSize/5,3*squareSize/5),
      position: Vector2(1.1*(-4*squareSize/10),-3*squareSize/60),
      table: gameData.rooms[0].tables[0],
      relativeRotationIndex: 0,
      showGridOverlay: true
    );

    final MyTableComponent table2 = MyTableComponent(
      size: Vector2(3*squareSize/5,3*squareSize/5),
      position: Vector2(1.1*(4*squareSize/10),-3*squareSize/60),
      table: gameData.rooms[0].tables[1],
      relativeRotationIndex: 1,
      showGridOverlay: true
    );

    world.add(background);
    world.add(minimap);
    world.add(table1);
    world.add(table2);


    // make the camera follow something
    // camera.follow();

    // debugMode = true;
  }
}