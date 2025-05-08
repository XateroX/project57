import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';

class GameTable extends ChangeNotifier{
  late List<GameItem> childItems;
  static int cellCount = 10;

  GameTable(
    {
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

  void alignItemsToGrid(){
    for (GameItem item in childItems){
      item.alignToGrid();
    }
  }

  static GameTable blank(){
    GameTable blankTable = GameTable(
      childItems: []
    );

    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Sword"
      )
    );

    return blankTable;
  }
}