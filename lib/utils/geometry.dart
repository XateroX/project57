import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

Path getLShapedPath(
  double width, 
  double height,
  {
    double rotateByRadians = 0,
    double scaleByFactor = 1.0,
    Offset shiftByOffset = const Offset(0,0),
  }
){
  // create base L-shape
  Path lShapedPath = Path();
  lShapedPath.moveTo(0,0);
  lShapedPath.lineTo(width,0);
  lShapedPath.lineTo(width,height/2);
  lShapedPath.lineTo(width/2,height/2);
  lShapedPath.lineTo(width/2,height);
  lShapedPath.lineTo(0,height);
  lShapedPath.close();

  // matrices to transform the tables
  final vector64.Matrix4 rotationMat = vector64.Matrix4.rotationZ(rotateByRadians);
  final vector64.Matrix4 shrinkMat = vector64.Matrix4.identity()..scale(scaleByFactor);
  final Float64List rotationBuffer = rotationMat.storage;
  final Float64List shrinkBuffer = shrinkMat.storage;

  // create the transformed shape
  lShapedPath = lShapedPath.transform(shrinkBuffer);
  lShapedPath = lShapedPath.shift(shiftByOffset);
  lShapedPath = lShapedPath.transform(rotationBuffer);

  // lShapedPath = lShapedPath.shift(Offset(width/2,height/2));

  return lShapedPath;
}

/// Returns grid points inside an L-shaped area
List<Offset> getLShapeGridPoints({
  required double width,
  required double height,
  required double cellSize,
  double rotateByRadians = 0,
  double scaleByFactor = 1.0,
  Offset shiftByOffset = const Offset(0, 0),
}) {
  cellSize = width * cellSize * scaleByFactor;

  final List<Offset> gridPoints = [];

  final int cols = (width / cellSize).ceil();
  final int rows = (height / cellSize).ceil();

  // Define a path of the original L-shape
  final Path lShape = getLShapedPath(
    width, 
    height,
    // rotateByRadians: rotateByRadians,
    scaleByFactor: scaleByFactor,
    shiftByOffset: shiftByOffset
  );

  // Use the same transforms as used on the Path
  final vector64.Matrix4 transformSansRotate = vector64.Matrix4.identity()
    ..translate(shiftByOffset.dx, shiftByOffset.dy);
  
  final vector64.Matrix4 transformRotate = vector64.Matrix4.identity()
    // ..scale(scaleByFactor) // Dont need to scale again, results in a double scale
    ..rotateZ(rotateByRadians);

  for (int j = 1; j <= rows-1; j++) {
    for (int i = 1; i <= cols-1; i++) {
      final Offset point = Offset(i * cellSize, j * cellSize);
      final vector64.Vector3 v = vector64.Vector3(point.dx, point.dy, 0);
      v.applyMatrix4(transformSansRotate);

      // Check if this point is inside the original L shape
      // if (lShape.contains(Offset(v.x, v.y))) {
      //   if (!isPointOnPathEdge(lShape, Offset(v.x, v.y), tolerance: 2)) {
          v.applyMatrix4(transformRotate);
          gridPoints.add(Offset(v.x, v.y));
      //   }
      // }
    }
  }

  return gridPoints;
}


bool isPointOnPathEdge(Path path, Offset point, {double tolerance = 1.0}) {
  final pathMetrics = path.computeMetrics();
  for (final metric in pathMetrics) {
    final extractPath = metric.extractPath(0, metric.length);
    for (final segment in extractPath.computeMetrics()) {
      final extracted = segment.extractPath(0, segment.length);

      final pathPoints = _samplePathPoints(extracted, segment.length);
      for (int i = 0; i < pathPoints.length - 1; i++) {
        final p1 = pathPoints[i];
        final p2 = pathPoints[i + 1];
        final distance = _distanceFromPointToLineSegment(point, p1, p2);
        if (distance <= tolerance) {
          return true;
        }
      }
    }
  }
  return false;
}

List<Offset> _samplePathPoints(Path path, double length, {double resolution = 5.0}) {
  final List<Offset> points = [];
  for (double i = 0; i <= length; i += resolution) {
    final tangent = path.computeMetrics().first.getTangentForOffset(i);
    if (tangent != null) {
      points.add(tangent.position);
    }
  }
  return points;
}

double _distanceFromPointToLineSegment(Offset p, Offset a, Offset b) {
  final ap = p - a;
  final ab = b - a;
  final ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
  final apDotAb = ap.dx * ab.dx + ap.dy * ab.dy;
  final t = (ab2 != 0) ? (apDotAb / ab2).clamp(0.0, 1.0) : 0.0;
  final closest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - closest).distance;
}

Tuple2<int, int> getBadSector(int relativeRotationIndex) {
  switch (relativeRotationIndex) {
    case 0:
      return const Tuple2(1, 1);
    case 1:
      return const Tuple2(-1, 1);
    case 2:
      return const Tuple2(-1, -1);
    case 3:
      return const Tuple2(1, -1);
    default:
      return const Tuple2(0, 0);
  }
}

Tuple2<int,int> getBadness(int relativeRotationIndex, Tuple2<int,int> pos){
  Tuple2<int,int> badSector = getBadSector(relativeRotationIndex);

  // Measure how far into the bad zone each axis is
  int badnessX = badSector.item1 != 0
    ? (badSector.item1 > 0 ? pos.item1 - 4 : 4 - pos.item1)
    : 0;

  int badnessY = badSector.item2 != 0
    ? (badSector.item2 > 0 ? pos.item2 - 4 : 4 - pos.item2)
    : 0;
  return Tuple2(badnessX, badnessY);
}

Offset relativeRotationOffset(Offset offset, int relativeRotationIndex){
  // rotate the calculated coords to match the rotation
  offset = switch (relativeRotationIndex) {
    0 => Offset(offset.dx, offset.dy),
    1 => Offset(offset.dy, offset.dx),
    2 => Offset(-offset.dx, -offset.dy),
    3 => Offset(-offset.dy, -offset.dx),
    _ => Offset(offset.dx, offset.dy),
  };
  return offset;
}