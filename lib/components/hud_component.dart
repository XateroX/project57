import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:project57/game.dart';

class BorderHud extends PositionComponent {
  Color _color = Colors.transparent;
  String _text = "";

  BorderHud({
    super.position,
    super.size,
  });

  @override
  void onLoad(){
    anchor = Anchor.center;

    (findGame() as MyFlameGame).currentPosition.addListener(_onCameraMoved);
    (findGame() as MyFlameGame).currentColor.addListener(_onColorChanged);
    (findGame() as MyFlameGame).currentHUDText.addListener(_onTextChanged);
  }

  void _onCameraMoved() => position = (findGame() as MyFlameGame).currentPosition.value ?? Vector2(0,0);
  void _onColorChanged() => _color = (findGame() as MyFlameGame).currentColor.value;
  void _onTextChanged() => _text = (findGame() as MyFlameGame).currentHUDText.value;

  @override
  void render(Canvas canvas) {
    final Paint paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;

    final rect = Rect.fromLTRB(0, 0, size.x, size.y);
    canvas.drawRect(rect, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: TextStyle(
          color: _color,
          fontSize: size.y / 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y - textPainter.height - size.y / 10,
      ),
    );
  }
}