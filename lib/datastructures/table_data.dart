import 'package:project57/datastructures/item_data.dart';

class GameTable {
  late List<GameItem> childItems;

  GameTable(
    {
      List<GameItem>? childItems,
    }
  ) : childItems = childItems ?? [];

  static GameTable blank(){
    return GameTable(
      childItems: [
        GameItem(),
        GameItem(),
        GameItem(),
      ]
    );
  }
}