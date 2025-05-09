import 'package:flutter/material.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

// ignore: camel_case_types
enum ProcessingType {
  NONE,
  GROUND,
  BOILED,
  COOKED
}

extension ProcessingTypeExtension on ProcessingType {
  String get name {
    switch(this) {
      case ProcessingType.NONE:
        return "None";
      case ProcessingType.GROUND:
        return "Ground";
      case ProcessingType.BOILED:
        return "Boiled";
      case ProcessingType.COOKED:
        return "Cooked";
      default:
        return "None";
    }
  }

  Color get color {
    switch(this) {
      case ProcessingType.NONE:
        return Colors.grey;
      case ProcessingType.GROUND:
        return Colors.brown;
      case ProcessingType.BOILED:
        return Colors.lightBlueAccent;
      case ProcessingType.COOKED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int get count {
    switch(this) {
      case ProcessingType.NONE:
        return 0;
      case ProcessingType.GROUND:
        return 3;
      case ProcessingType.BOILED:
        return 1;
      case ProcessingType.COOKED:
        return 1;
      default:
        return 0;
    }
  }
}

class GameItem extends ChangeNotifier {
  late String id;

  // machine variables
  bool isMachine;
  Tuple2<int,int> inputOffset;
  Tuple2<int,int> outputOffset;

  String name;
  // grid indices
  Tuple2<int,int> pos = const Tuple2(0,0);
  // continuous offset as a 
  Offset posOffset = Offset(0,0);
  GameTable? parentTable;

  // rotation
  int relativeRotationIndex;

  // processing done to this item
  List<ProcessingType> processing;
  ProcessingType processingKind;
  bool processingReady = true;

  GameItem({
    required this.parentTable,
    this.name = "",
    this.isMachine = false,
    this.inputOffset = const Tuple2(-1,0),
    this.outputOffset = const Tuple2(1,0),
    this.relativeRotationIndex = 0,
    this.processing = const [],
    this.processingKind = ProcessingType.NONE,
  }){
    id = Uuid().v4();
  }

  void addProcessing(ProcessingType process){
    processing = [...processing, process];
    notifyListeners();
  }

  void alignToGrid(){
    pos = Tuple2(
      (posOffset.dx-1).round().clamp(0, 8),
      (posOffset.dy-1).round().clamp(0, 8),
    );

    if (parentTable != null){
      Tuple2<int,int> badsector = getBadSector(parentTable!.relativeRotationIndex);
      Tuple2<int,int> badness = getBadness(parentTable!.relativeRotationIndex, pos);

      if (badness.item1 >= 0 && badness.item2 >= 0) {
        if (badness.item1 < badness.item2) {
          // Clamp X only
          pos = Tuple2(
            badsector.item1 > 0 ? 3 : 5,
            pos.item2,
          );
        } else {
          // Clamp Y only
          pos = Tuple2(
            pos.item1,
            badsector.item2 > 0 ? 3 : 5,
          );
        }
      }
    }
    // rotate the calculated coords to match the rotation of the table
    pos = switch (parentTable!.relativeRotationIndex) {
      0 => Tuple2(pos.item1, pos.item2),
      1 => Tuple2(pos.item2, 8-pos.item1),
      2 => Tuple2(8-pos.item1, 8-pos.item2),
      3 => Tuple2(8-pos.item2, pos.item1),
      _ => Tuple2(pos.item1, pos.item2),
    };

    posOffset = Offset(0,0);
    notifyListeners();
  }

  void setPos(Tuple2<int,int> newPos){
    pos = newPos;
    notifyListeners();
  }

  updateOffset(Offset newOffset){
    posOffset = newOffset;
    notifyListeners();
  }

  bool processInputItems(){
    bool shouldBeRecursive = false;
    if (!isMachine) return false;
    if (!processingReady) return false;
    List<GameItem> tempCopyList = [...parentTable!.childItems];

    Tuple2<int,int> relativeInputOffset = relativeRotationTuple(inputOffset, relativeRotationIndex);
    Tuple2<int,int> relativeOutputOffset = relativeRotationTuple(outputOffset, relativeRotationIndex);

    for (GameItem item in tempCopyList){
      if (
        item.pos.item1 == pos.item1+relativeInputOffset.item1 && 
        item.pos.item2 == pos.item2+relativeInputOffset.item2 && 
        !item.isMachine
      ){
        parentTable!.childItems.remove(item);

        item.addProcessing(processingKind);
        item.setPos(Tuple2(pos.item1+relativeOutputOffset.item1, pos.item2+relativeOutputOffset.item2));

        for (int i = 0; i < processingKind.count; i++){
          GameItem newItem = GameItem(
            parentTable: item.parentTable,
            name: item.name,
            isMachine: item.isMachine,
            inputOffset: item.inputOffset,
            outputOffset: item.outputOffset,
            relativeRotationIndex: item.relativeRotationIndex,
            processing: item.processing,
            processingKind: item.processingKind,
          );
          newItem.setPos(Tuple2(pos.item1+relativeOutputOffset.item1, pos.item2+relativeOutputOffset.item2));
          parentTable!.addItem(newItem);
        }
        shouldBeRecursive = true;
        processingReady = false;
        notifyListeners();
      }
    }
    return shouldBeRecursive;
  }
}