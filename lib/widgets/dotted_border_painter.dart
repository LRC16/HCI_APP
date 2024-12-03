import 'package:flutter/material.dart';



class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gapWidth;

  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dash = 3.0;
    final double gap = gapWidth;
    
    // Top line
    double currentX = 0;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dash, 0),
        paint,
      );
      currentX += dash + gap;
    }

    // Right line
    double currentY = 0;
    while (currentY < size.height) {
      canvas.drawLine(
        Offset(size.width, currentY),
        Offset(size.width, currentY + dash),
        paint,
      );
      currentY += dash + gap;
    }

    // Bottom line
    currentX = size.width;
    while (currentX > 0) {
      canvas.drawLine(
        Offset(currentX, size.height),
        Offset(currentX - dash, size.height),
        paint,
      );
      currentX -= dash + gap;
    }

    // Left line
    currentY = size.height;
    while (currentY > 0) {
      canvas.drawLine(
        Offset(0, currentY),
        Offset(0, currentY - dash),
        paint,
      );
      currentY -= dash + gap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}