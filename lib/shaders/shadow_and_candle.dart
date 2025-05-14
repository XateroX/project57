

import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/post_process.dart';
import 'package:vector_math/vector_math.dart';

class ShadowAndCandlePostProcess extends PostProcess {
  late List<Vector2> randomShadowLocations;

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
        ..setVectors(randomShadowLocations)
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