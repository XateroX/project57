import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project57/components/item_component.dart';
import 'package:project57/datastructures/item_data.dart';
import 'package:project57/game.dart';

class MyItemSummaryComponent extends PositionComponent {
  GameItem? summaryItem;
  late double plotWidth;
  late double plotHeight;

  double totalTime = 0.0;

  MyItemSummaryComponent({
    required super.size,
    required super.position,
  }){
    plotWidth = width*0.9;
    plotHeight = width*0.9;
  }

  @override
  void onLoad(){
    super.onLoad();
    anchor = Anchor.center;
    (findGame() as MyFlameGame).detailViewingItem.addListener(_summaryItemChanged);
    // (findGame() as MyFlameGame).targetPosition.addListener(_cameraTargetPositionChanged);
    (findGame() as MyFlameGame).currentPosition.addListener(_cameraActualPositionChanged);

    if ((findGame() as MyFlameGame).detailViewingItem.value == null){
      position += Vector2(10*width, 0);
    } else {
      summaryItem = (findGame() as MyFlameGame).detailViewingItem.value;
      position = ((findGame() as MyFlameGame).targetPosition.value ?? Vector2(0,0))+Vector2(width, height/2);
    }
  }

  void _cameraTargetPositionChanged(){
    if (summaryItem != null){
      position = ((findGame() as MyFlameGame).targetPosition.value ?? Vector2(0,0))+Vector2(width, height/2);
    } else {
      position += Vector2(10*width, 0);
    }
  }

  void _cameraActualPositionChanged(){
    if (summaryItem != null){
      position = ((findGame() as MyFlameGame).currentPosition.value ?? Vector2(0,0))+Vector2(width, height/2);
    } else {
      position += Vector2(10*width, 0);
    }
  }

  void _summaryItemChanged(){
    // the item changed so stop listening to the (currently non-null) old summary item
    if ((findGame() as MyFlameGame).detailViewingItem.value == null && summaryItem != null){
      summaryItem!.removeListener(_summaryItemValuesChanged);
    }
    summaryItem = (findGame() as MyFlameGame).detailViewingItem.value;
    if (summaryItem != null){
      position = ((findGame() as MyFlameGame).targetPosition.value ?? Vector2(0,0))+Vector2(width, height/2);
      summaryItem!.addListener(_summaryItemValuesChanged);
    } else {
      position += Vector2(10*width, 0);
    }
  }

  void _summaryItemValuesChanged(){

  }

  @override
  void update(double dt){
    super.update(dt);
    totalTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    double zoom = (findGame() as MyFlameGame).camera.viewfinder.zoom;
    canvas.scale(1/zoom);

    _drawMainContent(canvas);
    _drawItemPlot(canvas);

    canvas.scale(zoom);
  }

  void _drawMainContent(Canvas canvas){
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0,0), 
        width: width, 
        height: height
      ), 
      Paint()
        ..color = Colors.white.withAlpha(255)
    );
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
  }

  void _drawItemPlot(Canvas canvas){
    if (summaryItem == null){return;}

    // take a section of the area as the plot area
    double plotYMax = 3.0*(summaryItem!.stateVector[3]+1);
    double plotXMax = 3.0*(summaryItem!.stateVector[3]+1);
    double divisionSize = max((2*plotXMax/6).floor(),1) * 0.5;

    canvas.drawRect(
      Rect.fromCenter(center: Offset(0,0), 
        width: plotWidth, 
        height: plotHeight
      ), 
      Paint()
        ..color = const Color.fromARGB(255, 0, 0, 0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width/100
    );

    // canvas offset (view-wise), center is always (0,0)
    // Offset translateOffset = Offset(
    //   cos(0.5*totalTime)*plotWidth/4, 
    //   sin(0.2*totalTime).abs()*plotHeight/3
    // );
    Offset translateOffset = Offset(
      (summaryItem!.stateVector.x / plotXMax)*plotWidth/2,
      (summaryItem!.stateVector.y / plotYMax)*plotHeight/2,
    );

    // draw axes (pixel-space units)
    canvas.translate(-translateOffset.dx, translateOffset.dy);
    if ((translateOffset.dx) > -plotWidth/2 && (translateOffset.dx) < plotWidth/2){
      canvas.drawLine(
        Offset(0, plotHeight/2 - translateOffset.dy), 
        Offset(0, -plotHeight/2 - translateOffset.dy),
        Paint()
          ..color = Colors.black
          ..strokeWidth = width/200
      );
    }
    if ((translateOffset.dy) > -plotHeight/2 && (translateOffset.dy) < plotHeight/2){
      canvas.drawLine(
        Offset(-plotWidth/2 + translateOffset.dx, 0), 
        Offset(plotWidth/2 + translateOffset.dx, 0),
        Paint()
          ..color = Colors.black
          ..strokeWidth = width/200
      );
    }

    // draw gray sub-axes at intervals with labels
    for (int i = -100; i < 100; i++) {
      double x = (i * (divisionSize) / plotXMax)*(plotWidth/2);
      if ((x-translateOffset.dx) >= -plotWidth / 2 && (x-translateOffset.dx) <= plotWidth / 2) {
        canvas.drawLine(
          Offset(x, plotHeight / 2 - translateOffset.dy),
          Offset(x, -plotHeight / 2 - translateOffset.dy),
          Paint()
            ..color = Colors.grey.withAlpha(100)
            ..strokeWidth = width / 300,
        );
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: (i * (divisionSize)).toStringAsFixed(1),
            style: TextStyle(
              color: Colors.black,
              fontSize: width / 50,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - 1.3*textPainter.width, plotHeight/2 - translateOffset.dy - 1.3*textPainter.height),
        );
      }
      double y = (i * (divisionSize) / plotYMax)*(plotHeight/2);
      if ((y+translateOffset.dy) >= -plotHeight/2 && (y+translateOffset.dy) <= plotHeight/2) {
        canvas.drawLine(
          Offset(-plotWidth / 2 + translateOffset.dx, y),
          Offset(plotWidth / 2 + translateOffset.dx, y),
          Paint()
            ..color = Colors.grey.withAlpha(100)
            ..strokeWidth = width / 300,
        );
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: (-i * (divisionSize)).toStringAsFixed(1),
            style: TextStyle(
              color: Colors.black,
              fontSize: width / 60,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset( plotWidth/2 + translateOffset.dx - 1.3*textPainter.width, y - 1.3*textPainter.height),
        );
      }
    }
    canvas.translate(translateOffset.dx, -translateOffset.dy);

    _drawItemCircle(canvas);
  }

  _drawItemCircle(Canvas canvas){
    double circleDiameter = plotWidth/25;
    double colorOffset = 1*totalTime + (sin(1.0*totalTime)+1)/2;

    // draw hue arc
    Paint arcPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = width/100
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i++){
      arcPaint.color = HSVColor.fromAHSV(1, ((360*colorOffset + i).toInt()%360).toDouble(), 1, 1).toColor();
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(0,0), 
          width: circleDiameter, 
          height: circleDiameter
        ),
        (i/360) * 2*pi,
        (1/360) * 2*pi,
        false,
        arcPaint
      );
    }

    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: "${(summaryItem!.stateVector.x).toStringAsFixed(1)}, ${(summaryItem!.stateVector.y).toStringAsFixed(1)}",
        style: TextStyle(
          color: Colors.black,
          fontSize: width / 50,
          fontWeight: FontWeight.bold
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset( -textPainter.width/2,-textPainter.height/2 - circleDiameter),
    );
  }
}