import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

class GameTable extends ChangeNotifier{
  late String id;

  late List<GameItem> childItems;
  static int cellCount = 10;
  int relativeRotationIndex;
  late bool recursiveMachineInteractions;

  GameTable(
    {
      required this.relativeRotationIndex,
      this.childItems = const [],
    }
  ){
    id = Uuid().v4();
    for (GameItem item in childItems){
      item.addListener(notifyListeners);
    }
    recursiveMachineInteractions = true;
  }

  void addItem(GameItem item){
    childItems = List.from(childItems)..add(item);
    notifyListeners();
  }

  void removeItem(GameItem item){
    childItems = List.from(childItems)..remove(item);
    notifyListeners();
  }

  void handleItemsPlaced(List<GameItem> items, int visualParentRelativeIndex){
    alignItemsToGrid(items, visualParentRelativeIndex);
    handleMachineInteractions(items);
    spaceOutAllItems();
  }

  void handleMachineInteractions(List<GameItem> items){
    while(recursiveMachineInteractions){
      recursiveMachineInteractions = false;
      for (GameItem item in childItems.where((element) => element.isMachine == true).toList()){
        bool? processResult = item.processInputItems();
        if (processResult!=null){
          recursiveMachineInteractions = processResult;
        }
      }
    }
    recursiveMachineInteractions = true;
    for (GameItem item in childItems.where((element) => element.isMachine == true).toList()){
      item.processingReady = true;
    }
    notifyListeners();
  }

  void alignItemsToGrid(List<GameItem> itemsToAlign, int visualParentRelativeIndex){
    for (GameItem item in itemsToAlign){
      item.alignToGrid(visualParentRelativeIndex);
    }
  }

  void spaceOutAllItems(){
    for (GameItem gItem1 in childItems){
      for (GameItem gItem2 in childItems){
        if (gItem1.id==gItem2.id) continue;
        if (
          gItem1.pos.item1 == gItem2.pos.item1 && 
          gItem1.pos.item2 == gItem2.pos.item2
        ){
          List<Tuple2<int,int>> spaceOptions = getAllAdjacentAvailableSpaces(gItem1.pos);
          if (spaceOptions.isEmpty){continue;}
          gItem1.setPos(spaceOptions.first);
        }
      }
    }
  }

  List<Tuple2<int,int>> getAllAdjacentAvailableSpaces(Tuple2<int,int> center){
    List<Tuple2<int,int>> runningCollection = [];
    for (int i = -1; i <= 1; i++){
      for (int j = -1; j <= 1; j++){
        if (i==0 && j==0) continue;
        if (center.item1+i < 0 || center.item1+i >= cellCount-1) continue;
        if (center.item2+j < 0 || center.item2+j >= cellCount-1) continue;
        if (
          childItems.where(
            (element) => 
              element.pos.item1 == center.item1+i && 
              element.pos.item2 == center.item2+j
          ).toList().isEmpty
        ){
          runningCollection = [...runningCollection, Tuple2(center.item1+i, center.item2+j)];
        }
      }
    }
    return runningCollection;
  }

  static GameTable blank(int relativeRotationIndex){
    GameTable blankTable = GameTable(
      relativeRotationIndex: relativeRotationIndex,
      childItems: []
    );

    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Sword",
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,0);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Herbs"
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,1);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Iron Pot",
        isMachine: true,
        processingKind: ProcessingType.BOILED
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,2);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Iron Pot",
        isMachine: true,
        processingKind: ProcessingType.BOILED
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,3);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Iron Pot",
        isMachine: true,
        processingKind: ProcessingType.BOILED
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,4);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Iron Pot",
        isMachine: true,
        processingKind: ProcessingType.BOILED
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,5);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "P&M",
        isMachine: true,
        processingKind: ProcessingType.GROUND
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,6);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Gillyweed"
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,7);
    blankTable.addItem(
      GameItem(
        parentTable: blankTable,
        name: "Water"
      )
    );
    blankTable.childItems.last.pos = Tuple2(0,8);

    return blankTable;
  }
}