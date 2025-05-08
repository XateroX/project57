import 'package:project57/datastructures/game_room_data.dart';
import 'package:project57/datastructures/table_data.dart';

class GameOverallData {
  List<GameRoomData> rooms = [];
  int? currentRoomIndex;
  int? currentRoomPositionindex;

  void addInitialroom(){
    if (rooms.isNotEmpty) {
      throw Exception('You can only have one initial room');
    } else {
      GameRoomData initialRoom = GameRoomData(tables: []); 
      rooms.add(initialRoom);
      currentRoomIndex = 0;
      currentRoomPositionindex = 0;
    }
  }
}

