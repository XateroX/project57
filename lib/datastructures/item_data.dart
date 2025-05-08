import 'package:flutter/material.dart';
import 'package:project57/datastructures/table_data.dart';
import 'package:project57/utils/geometry.dart';
import 'package:tuple/tuple.dart';

class GameItem extends ChangeNotifier {
  String name;
  // grid indices
  Tuple2<int,int> pos = const Tuple2(0,0);
  // continuous offset as a 
  Offset posOffset = Offset(0,0);
  GameTable? parentTable;

  GameItem({
    required this.parentTable,
    this.name = ""
  });

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

  updateOffset(Offset newOffset){
    posOffset = newOffset;
    notifyListeners();
  }
}