import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

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

  for (int i = 0; i <= cols; i++) {
    for (int j = 0; j <= rows; j++) {
      final Offset point = Offset(i * cellSize, j * cellSize);
      final vector64.Vector3 v = vector64.Vector3(point.dx, point.dy, 0);
      v.applyMatrix4(transformSansRotate);

      // Check if this point is inside the original L shape
      if (lShape.contains(Offset(v.x, v.y))) {
        if (!isPointOnPathEdge(lShape, Offset(v.x, v.y), tolerance: 2)) {
          v.applyMatrix4(transformRotate);
          gridPoints.add(Offset(v.x, v.y));
        }
      }
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