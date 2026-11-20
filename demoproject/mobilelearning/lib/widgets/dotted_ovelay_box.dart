import 'package:flutter/material.dart';

class DottedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red // Dotted box color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashWidth = 9.0;
    final dashSpace = 5.0;
    double startX = 0;
    double startY = 0;

    // Draw top side
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    // Draw bottom side
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height),
          Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    // Draw left side
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    startY = 0;
    // Draw right side
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY),
          Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
