import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/game.dart';

class MyItemSummaryComponent extends PositionComponent {
  GameItem? summaryItem;

  MyItemSummaryComponent({
    required super.size,
    required super.position,
  }){
    // position += Vector2(10*width, 0);
  }

  @override
  void onLoad(){
    super.onLoad();
    anchor = Anchor.center;
    (findGame() as MyFlameGame).detailViewingItem.addListener(_summaryItemChanged);
  }

  void _summaryItemChanged(){
    summaryItem = (findGame() as MyFlameGame).detailViewingItem.value;
    if (summaryItem != null){
      position = ((findGame() as MyFlameGame).targetPosition ?? Vector2(0,0))+Vector2(width, height/2);
    } else {
      position += Vector2(10*width, 0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    double zoom = (findGame() as MyFlameGame).camera.viewfinder.zoom;
    canvas.scale(1/zoom);

    canvas.drawRect(Rect.fromCenter(center: Offset(0,0), width: width, height: height), Paint()..color = Colors.white.withAlpha(240));
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: summaryItem?.name ?? "No Item",
        style: TextStyle(
          color: Colors.black,
          fontSize: width/15,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width/2, 
        - height/2
      ),
    );

    canvas.scale(zoom);
  }
}