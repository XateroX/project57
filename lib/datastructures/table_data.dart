import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';

class GameTable extends ChangeNotifier{
  late List<GameItem> childItems;
  static int cellCount = 10;
  int relativeRotationIndex;

  GameTable(
    {
      required this.relativeRotationIndex,
      this.childItems = const [],
    }
  ){
    for (GameItem item in childItems){
      item.addListener(notifyListeners);
    }
  }

  void addItem(GameItem item){
    childItems.add(item);
    notifyListeners();
  }


  void alignItemsToGrid(List<GameItem> itemsToAlign){
    for (GameItem item in itemsToAlign){
      item.alignToGrid();
    }
  }

  static GameTable blank(int relativeRotationIndex){
    GameTable blankTable = GameTable(
      relativeRotationIndex: relativeRotationIndex,
      childItems: []
    );

    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Sword"
      )
    );
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Herbs"
      )
    );
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Iron Pot",
        isMachine: true
      )
    );

    return blankTable;
  }
}