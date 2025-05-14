import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';

class GameCarryTray extends ChangeNotifier {
  List<GameItem> items = [];

  GameCarryTray() {
    notifyListeners();
  }

  addItem(GameItem item) {
    items = List.from(items)..add(item);
    notifyListeners();
  }

  removeItem(GameItem item) {
    items = List.from(items)..remove(item);
    notifyListeners();
  }
}