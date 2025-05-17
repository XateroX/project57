import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/carry_tray_data.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:tuple/tuple.dart';

class GameOverallData extends ChangeNotifier {
  Set<Tuple2<int,int>> roomLocations = {};
  List<GameRoomData> rooms = [];
  int currentRoomIndex = 0;
  int currentRoomPositionindex = 0;
  GameCarryTray carryTray = GameCarryTray();

  GameOverallData(){
    carryTray.addListener(notifyListeners);
  }

  void addInitialroom(){
    if (rooms.isNotEmpty) {
      throw Exception('You can only have one initial room');
    } else {
      GameRoomData initialRoom = GameRoomData(); 
      initialRoom.addListener(notifyListeners);
      rooms.add(initialRoom);
      currentRoomIndex = 0;
      currentRoomPositionindex = 0;
      roomLocations.add(Tuple2(0,0));
    }
  }

  void createDungeonLayout(int numberOfRooms){
    for (int i = 0; i < numberOfRooms; i++){
      GameRoomData randomRoomInDungeon = rooms[Random().nextInt(rooms.length)];
      int randomIndexToMove = Random().nextInt(4); 

      Tuple2<int,int> newRoomPosition = getNewRoomPositionFromRoom(randomRoomInDungeon.pos, randomIndexToMove);

      if (!roomLocations.contains(newRoomPosition)){
        addRoomAtPosition(newRoomPosition);
      }
    }
  } 

  void addRoomAtPosition(Tuple2<int,int> newRoomPosition){
    if (roomLocations.contains(newRoomPosition)){return;}

    int randomAmountOfItems = (Random().nextInt(10) - 3).clamp(0, 7); // 7/10 chance to get something
    int randomAmountOfMachines = (Random().nextInt(10) - 8).clamp(0, 1); // 2/10 chance to get 1 machine
    roomLocations.add(newRoomPosition);
    GameRoomData newRoom = GameRoomData(
      tables: [
        GameTable.random(randomAmountOfItems,randomAmountOfMachines,0),
        GameTable.random(randomAmountOfItems,randomAmountOfMachines,1),
        GameTable.random(randomAmountOfItems,randomAmountOfMachines,2),
        GameTable.random(randomAmountOfItems,randomAmountOfMachines,3),
      ],
      pos: newRoomPosition
    );
    newRoom.addListener(notifyListeners);
    rooms.add(newRoom);
  }

  Tuple2<int,int> getNewRoomPositionFromRoom(Tuple2<int,int> existingPosition, int newRoomIndex){
    return switch (newRoomIndex) {
      0 => Tuple2(existingPosition.item1+0, existingPosition.item2-1),
      1 => Tuple2(existingPosition.item1+1, existingPosition.item2+0),
      2 => Tuple2(existingPosition.item1+0, existingPosition.item2+1),
      3 => Tuple2(existingPosition.item1-1, existingPosition.item2+0),
      _ => Tuple2(0,0),
    };
  }

  void setCurrentRoomPositionindex(int newIndex){
    currentRoomPositionindex = newIndex;
    notifyListeners();
  }

  void moveCurrentRoomIndex(int newIndex){
    Tuple2<int,int> newRoomPosition = getNewRoomPositionFromRoom(rooms[currentRoomIndex].pos, newIndex);

    if (!roomLocations.contains(newRoomPosition)){
      // For generating rooms when testing //
      // addRoomAtPosition(newRoomPosition);
      // currentRoomIndex!.value = rooms.length-1;
      // notifyListeners();
      // //
    } else {
      currentRoomIndex = rooms.indexOf(rooms.where((e) => e.pos == newRoomPosition).first);
    }
    notifyListeners();
  }
}

