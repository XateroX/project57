import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project57/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget();
  }
}

class BaseWidget extends StatefulWidget {
  const BaseWidget({super.key,});

  @override
  State<BaseWidget> createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {

  @override
  Widget build(BuildContext context) {
    
    return GameWidget(
      game: MyFlameGame()
    );
  }
}
