import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

// ignore: camel_case_types
enum ProcessingType {
  NONE,
  GROUND,
  BOILED,
  COOKED,
  COOLED,
  BATHE,
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
      case ProcessingType.COOLED:
        return "Cooled";
      case ProcessingType.BATHE:
        return "Bathe";
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
      case ProcessingType.COOLED:
        return Colors.purple;
      case ProcessingType.BATHE:
        return Colors.lightGreen;
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
      case ProcessingType.COOLED:
        return 1;
      case ProcessingType.BATHE:
        return 1;
      default:
        return 0;
    }
  }
}

class GameItem extends ChangeNotifier {
  // ignore: non_constant_identifier_names
  static int MAX_PROCESSING = 5;
  static List<GameItem> NORMAL_ITEMS = [
    GameItem(
      parentTable: null,
      name: "Gillyweed"
    ),
    GameItem(
      parentTable: null,
      name: "Mixed Herbs"
    ),
    GameItem(
      parentTable: null,
      name: "Jamba Juice"
    ),
    GameItem(
      parentTable: null,
      name: "Bean Stalk"
    ),
    GameItem(
      parentTable: null,
      name: "Chaulk"
    ),
    GameItem(
      parentTable: null,
      name: "Gillyweed"
    ),
    GameItem(
      parentTable: null,
      name: "Water"
    ),
    GameItem(
      parentTable: null,
      name: "Blue Crystal"
    ),
    GameItem(
      parentTable: null,
      name: "Purple Crystal"
    ),
    GameItem(
      parentTable: null,
      name: "White Crystal"
    ),
    GameItem(
      parentTable: null,
      name: "Green Crystal"
    ),
    GameItem(
      parentTable: null,
      name: "Huge Mushroom"
    ),
    GameItem(
      parentTable: null,
      name: "Forest Mushroom"
    ),
  ];
  static List<GameItem> MACHINE_ITEMS = [
    GameItem(
      parentTable: null,
      name: "Iron Pot",
      isMachine: true,
      processingKind: ProcessingType.BOILED,
      processingDuration: 100,
    ),
    GameItem(
      parentTable: null,
      name: "P&M",
      isMachine: true,
      processingKind: ProcessingType.GROUND,
      processingDuration: 100,
    ),
    GameItem(
      parentTable: null,
      name: "Stove",
      isMachine: true,
      processingKind: ProcessingType.COOKED,
      processingDuration: 200,
    ),
    GameItem(
      parentTable: null,
      name: "Cooler",
      isMachine: true,
      processingKind: ProcessingType.COOLED,
      processingDuration: 200,
    ),
    GameItem(
      parentTable: null,
      name: "Bath",
      isMachine: true,
      processingKind: ProcessingType.BATHE,
      processingDuration: 300,
    ),
  ];

  late String id;

  // machine variables
  bool isMachine;
  bool currentlyProcessing = false;
  double processingRatio = 0.0;
  int processingDuration;
  Tuple2<int,int> inputOffset;
  Tuple2<int,int> outputOffset;
  bool processingReady = true;
  List<GameItem> itemsBeingProcessed = [];
  ProcessingType processingKind;

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
  // (Wetness, Temperature, PH, Groundness)
  v64.Vector4 stateVector = v64.Vector4(0,0,0,0);

  GameItem({
    required this.parentTable,
    this.name = "",
    this.isMachine = false,
    this.inputOffset = const Tuple2(-1,0),
    this.outputOffset = const Tuple2(1,0),
    this.relativeRotationIndex = 0,
    this.processing = const [],
    this.processingKind = ProcessingType.NONE,
    this.processingDuration = 600,
  }){
    id = Uuid().v4();
  }

  void generateNewId(){
    id = Uuid().v4();
  }

  void addProcessing(ProcessingType process){
    processing = [...processing, process];
    notifyListeners();
  }

  v64.Vector4 _getProcessingVector(){
    switch (processingKind) {
      case ProcessingType.BOILED:
        return v64.Vector4(0.5,0.5,0.0,0.0);
      case ProcessingType.GROUND:
        return v64.Vector4(0.0,0.1,0.0,0.5);
      case ProcessingType.COOKED:
        return v64.Vector4(0.0,1.0,0.0,0.0);
      case ProcessingType.COOLED:
        return v64.Vector4(0.0,-1.0,0.0,-0.5);
      case ProcessingType.BATHE:
        return v64.Vector4(1.0,0.0,0.0,0.0);
      case ProcessingType.NONE:
        return v64.Vector4(0,0,0,0);
      }
  }

  void decayStateVector(){
    if (stateVector[1].abs() > 0.1){
      stateVector[1] = stateVector[1]*(1-0.0005*(1/(1+stateVector[3].abs())));
    }
  }


  void alignToGrid(int visualParentRelativeIndex){
    pos = Tuple2(
      (posOffset.dx-1).round().clamp(0, 8),
      (posOffset.dy-1).round().clamp(0, 8),
    );

    if (parentTable != null){
      Tuple2<int,int> badsector = getBadSector(visualParentRelativeIndex);
      Tuple2<int,int> badness = getBadness(visualParentRelativeIndex, pos);

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
    pos = switch (visualParentRelativeIndex) {
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

  void setPosOffset(Offset newPosOffset){
    posOffset = newPosOffset;
    notifyListeners();
  }

  updateOffset(Offset newOffset){
    posOffset = newOffset;
    notifyListeners();
  }

  bool? processInputItems(){
    bool? shouldBeRecursive;
    if (!isMachine) return null;
    if (!processingReady) return null;
    List<GameItem> tempCopyList = [...parentTable!.childItems];

    Tuple2<int,int> relativeInputOffset = relativeRotationTuple(inputOffset, relativeRotationIndex);
    Tuple2<int,int> relativeOutputOffset = relativeRotationTuple(outputOffset, relativeRotationIndex);

    for (GameItem item in tempCopyList){
      if (
        item.pos.item1 == pos.item1+relativeInputOffset.item1 && 
        item.pos.item2 == pos.item2+relativeInputOffset.item2 && 
        !item.isMachine &&
        item.processing.length < GameItem.MAX_PROCESSING
      ){
        // add it to the list and set flags
        parentTable!.removeItem(item);
        itemsBeingProcessed.add(item);
        currentlyProcessing = true;
        processingReady = false;
      }
    }
    return shouldBeRecursive;
  }

  void processMyItems(){
    List<GameItem> tempItemsBeingProcessed = [...itemsBeingProcessed];

    Tuple2<int,int> relativeOutputOffset = relativeRotationTuple(outputOffset, relativeRotationIndex);
    for (GameItem item in tempItemsBeingProcessed){
      v64.Vector4 processingVector = _getProcessingVector().scaled((1+item.stateVector[3])/(processingDuration));
      processingVector[3] = processingVector[3] * (1/(1+item.stateVector[3])); // non-exponential groundness
      item.stateVector.add(processingVector);

      if (processingRatio >= 1.0){
        item.setPos(Tuple2(pos.item1+relativeOutputOffset.item1, pos.item2+relativeOutputOffset.item2));
        itemsBeingProcessed.remove(item);
        parentTable!.addItem(item);
        if (itemsBeingProcessed.isEmpty){
          currentlyProcessing = false;
          processingReady = true;
        }
      }
    }
  }

  Future<void> completeMachineProcessingIn(
    Duration duration,
    FutureOr<void> Function() processCompletedCallback, 
  ){
    return Future.delayed(duration, processCompletedCallback);
  }

  // LOOPING GAMEPLAY FUNCTIONS //
  void gameTick(){
    if (isMachine){
      if (currentlyProcessing){
        if (processingRatio <= 1.0){
          processingRatio += 1/processingDuration;
          if (processingRatio > 1.0){
            processingRatio = 1.0;
          }
          processMyItems();
          notifyListeners();
        }
      } else {
        processingRatio = 0.0;
      }
    } else {
      decayStateVector();
    }
  }
  //  //

  GameItem copy(){
    return GameItem(
      parentTable: parentTable,
      name: name,
      isMachine: isMachine,
      inputOffset: inputOffset,
      outputOffset: outputOffset,
      relativeRotationIndex: relativeRotationIndex,
      processing: processing,
      processingKind: processingKind,
      processingDuration: processingDuration
    );
  }

  destroy(){
    parentTable!.removeItem(this);
    notifyListeners();
  }
}