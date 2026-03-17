import 'package:flutter/material.dart';

class ArOverlayPainter extends CustomPainter {
  final Offset? targetCoords;
  final bool isPulsing;

  ArOverlayPainter({
    required this.targetCoords,
    required this.isPulsing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (targetCoords == null) return;

    final paintRing = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final paintOverlay = Paint()
      ..color = Colors.yellowAccent.withOpacity(isPulsing ? 0.4 : 0.1)
      ..style = PaintingStyle.fill;

    // The logic to 'normalize' coordinates to the mobile screen size
    // For now, draw at the passed raw coordinates
    canvas.drawCircle(targetCoords!, 40, paintOverlay);
    canvas.drawCircle(targetCoords!, 40, paintRing);
  }

  @override
  bool shouldRepaint(covariant ArOverlayPainter oldDelegate) {
    return oldDelegate.targetCoords != targetCoords ||
           oldDelegate.isPulsing != isPulsing;
  }
}
