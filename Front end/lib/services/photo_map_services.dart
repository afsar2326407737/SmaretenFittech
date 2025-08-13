import 'dart:ui';

import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List keypoints;
  final List<List<int>> connections;
  PosePainter(this.keypoints, this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw lines
    for (var pair in connections) {
      if (pair[0] < keypoints.length && pair[1] < keypoints.length) {
        final p1 = keypoints[pair[0]];
        final p2 = keypoints[pair[1]];
        canvas.drawLine(
          Offset(p1['x'] * size.width, p1['y'] * size.height),
          Offset(p2['x'] * size.width, p2['y'] * size.height),
          linePaint,
        );
      }
    }

    // Draw points
    for (var point in keypoints) {
      final dx = point['x'] * size.width;
      final dy = point['y'] * size.height;
      canvas.drawCircle(Offset(dx, dy), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}