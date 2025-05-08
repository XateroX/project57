import 'package:flutter/material.dart';
import 'package:project57/datastructures/table_data.dart';
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
      (4.0+posOffset.dx).round(),
      (4.0+posOffset.dy).round(),
    );
    posOffset = Offset(0,0);
    notifyListeners();
  }

  updateOffset(Offset newOffset){
    posOffset = newOffset;
    notifyListeners();
  }
}