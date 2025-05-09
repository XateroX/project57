import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:tuple/tuple.dart';

class GameOverallData extends ChangeNotifier {
  Set<Tuple2<int,int>> roomLocations = {};
  List<GameRoomData> rooms = [];
  ValueNotifier<int>? currentRoomIndex;
  ValueNotifier<int>? currentRoomPositionindex;

  void addInitialroom(){
    if (rooms.isNotEmpty) {
      throw Exception('You can only have one initial room');
    } else {
      GameRoomData initialRoom = GameRoomData(); 
      initialRoom.addListener(notifyListeners);
      rooms.add(initialRoom);
      currentRoomIndex = ValueNotifier(0);
      currentRoomPositionindex = ValueNotifier(0);
      roomLocations.add(Tuple2(0,0));
    }
  }

  void setCurrentRoomPositionindex(int newIndex){
    currentRoomPositionindex!.value = newIndex;
    notifyListeners();
  }

  void moveCurrentRoomIndex(int newIndex){
    Tuple2<int,int> newRoomPosition = switch (newIndex) {
      0 => Tuple2(rooms[currentRoomIndex!.value].pos.item1+0, rooms[currentRoomIndex!.value].pos.item2-1),
      1 => Tuple2(rooms[currentRoomIndex!.value].pos.item1+1, rooms[currentRoomIndex!.value].pos.item2+0),
      2 => Tuple2(rooms[currentRoomIndex!.value].pos.item1+0, rooms[currentRoomIndex!.value].pos.item2+1),
      3 => Tuple2(rooms[currentRoomIndex!.value].pos.item1-1, rooms[currentRoomIndex!.value].pos.item2+0),
      _ => Tuple2(0,0),
    };

    if (!roomLocations.contains(newRoomPosition)){
      roomLocations.add(newRoomPosition);
      GameRoomData newRoom = GameRoomData(
        tables: [
          GameTable(
            relativeRotationIndex: 0
          ),
          GameTable(
            relativeRotationIndex: 1
          ),
          GameTable(
            relativeRotationIndex: 2
          ),
          GameTable(
            relativeRotationIndex: 3
          )
        ],
        pos: newRoomPosition
      );
      newRoom.addListener(notifyListeners);
      rooms.add(newRoom);
      currentRoomIndex!.value = rooms.indexOf(newRoom);
      notifyListeners();
    } else {
      currentRoomIndex!.value = rooms.indexOf(rooms.where((e) => e.pos == newRoomPosition).first);
    }
    notifyListeners();
  }
}

