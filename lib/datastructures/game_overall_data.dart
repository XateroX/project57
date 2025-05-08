import 'package:flutter/material.dart';
import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/datastructures/table_data.dart';

class GameOverallData extends ChangeNotifier {
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
    }
  }

  void setCurrentRoomPositionindex(int newIndex){
    currentRoomPositionindex!.value = newIndex;
    notifyListeners();
  }
}

