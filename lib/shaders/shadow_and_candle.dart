

import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/post_process.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class ShadowAndCandlePostProcess extends PostProcess {
  late List<Vector2> randomShadowLocations;
  ValueNotifier<Vector2> mousePos;
  ValueNotifier<List<Vector2>> extraCandleLocations;

  ShadowAndCandlePostProcess({
    required this.mousePos,
    required this.extraCandleLocations,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fragmentProgram = await FragmentProgram.fromAsset(
      'assets/shaders/shadowandcandles.frag',
    );

    randomShadowLocations = List.generate(10, (index) => Vector2.random());
  }

  late final FragmentProgram _fragmentProgram;
  late final FragmentShader _fragmentShader = _fragmentProgram.fragmentShader();

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  late final myPaint = Paint()..shader = _fragmentShader;


  @override
  void postProcess(Vector2 size, Canvas canvas) {
    final preRenderedSubtree = rasterizeSubtree();

    _fragmentShader.setFloatUniforms((value) {
      value
        ..setFloat(extraCandleLocations.value.length.toDouble()+1)
        ..setVectors(
          extraCandleLocations.value.map(
            (v) => Vector2(v.x*(1/size.x), v.y*(1/size.y))
          ).toList()
          +[Vector2(mousePos.value.x*(1/size.x), mousePos.value.y*(1/size.y))]
          +List.generate(16-1-extraCandleLocations.value.length, (index) => Vector2(2000,2000))
        )
        ..setVector(size)
        ..setFloat(_time);
    });

    _fragmentShader.setImageSampler(0, preRenderedSubtree);

    canvas
      ..save()
      ..drawRect(Offset.zero & size.toSize(), myPaint)
      ..restore();
  }
}