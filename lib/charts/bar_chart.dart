import 'dart:math';

import 'package:flutter/material.dart';

class BarChartPainter extends CustomPainter {
  final List<int> data;
  final Color barColor;
  final Color textColor;
  final double fontSize;

  BarChartPainter({
    required this.data,
    required this.barColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5;

    final gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    const double topMargin = 20.0;
    const double bottomMargin = 20.0;
    const double leftMargin = 50.0;
    const double rightMargin = 50.0;
    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    final upperEnd = max(
      100,
      (data.reduce((a, b) => a > b ? a : b).toDouble() / 100).ceil() * 100,
    );

    const divisionCount = 48; // 1 division = 0.5 hours
    final barCount = min(divisionCount, data.length);
    final totalSpacing = chartWidth * 0.2;
    final barWidth = (chartWidth - totalSpacing) / divisionCount;
    final spacing = totalSpacing / (divisionCount + 1);

    // Draw Bars
    for (int i = 0; i < barCount; i++) {
      final count = data[i].toDouble();
      final normalizedValue = (count / upperEnd).clamp(0.0, 1.0);
      final currentBarHeight = chartHeight * normalizedValue;
      final left = leftMargin + spacing + i * (barWidth + spacing);
      final top = topMargin + chartHeight - currentBarHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, currentBarHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, barPaint);
    }

    // Draw upper grid line
    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(size.width - rightMargin, topMargin),
      gridPaint,
    );

    // Draw upper grid label
    _drawText(
      canvas,
      upperEnd.toStringAsFixed(0),
      Offset(size.width - rightMargin + 4, topMargin),
      alignment: Alignment.centerLeft,
    );

    // Draw middle grid line
    canvas.drawLine(
      Offset(leftMargin, chartHeight / 2 + topMargin),
      Offset(size.width - rightMargin, chartHeight / 2 + topMargin),
      gridPaint,
    );

    // Draw middle grid label
    _drawText(
      canvas,
      (upperEnd / 2).toStringAsFixed(0),
      Offset(size.width - rightMargin + 4, chartHeight / 2 + topMargin),
      alignment: Alignment.centerLeft,
    );

    // Draw X-Axis
    canvas.drawLine(
      Offset(leftMargin, chartHeight + topMargin),
      Offset(size.width - rightMargin, chartHeight + topMargin),
      axisPaint,
    );

    // Draw hour grids and labels
    for (int i = 0; i <= 48; i += 8) {
      final left = leftMargin + spacing + i * (barWidth + spacing);
      canvas.drawLine(
        Offset(left, chartHeight + topMargin),
        Offset(left, chartHeight + topMargin + 6),
        axisPaint,
      );
      _drawText(
        canvas,
        (i / 2).toStringAsFixed(0),
        Offset(left, chartHeight + topMargin + 8),
        alignment: Alignment.topCenter,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    Alignment alignment = Alignment.topLeft,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      position.dx - (textPainter.width * (alignment.x + 1) / 2),
      position.dy - (textPainter.height * (alignment.y + 1) / 2),
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
