import 'dart:math';

import 'package:flutter/material.dart';

class BarChartController {
  _BarChart? _state;

  void _attach(_BarChart state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void swipeLeft() {
    _state?._swipeLeft();
  }

  void swipeRight() {
    _state?._swipeRight();
  }

  void moveLeft() {
    _state?._moveLeft();
  }

  void moveRight() {
    _state?._moveRight();
  }
}

class BarChart extends StatefulWidget {
  final List<int> currentData;
  final List<int> previousData;
  final List<int> nextData;
  final Color barColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final BarChartController? controller;

  const BarChart({
    super.key,
    required this.currentData,
    required this.previousData,
    required this.nextData,
    required this.barColor,
    required this.textColor,
    required this.fontSize,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.controller,
  });

  @override
  State<BarChart> createState() => _BarChart();
}

class _BarChart extends State<BarChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragShift = 0.0;
  bool _isAnimating = false;
  double _lastWidth = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant BarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _animationController.dispose();
    super.dispose();
  }

  void _swipeLeft() {
    if (_isAnimating || widget.nextData.isEmpty) return;
    _animateTo(-_lastWidth, () {
      widget.onSwipeLeft?.call();
      setState(() {
        _dragShift = 0.0;
      });
    });
  }

  void _swipeRight() {
    if (_isAnimating || widget.previousData.isEmpty) return;
    _animateTo(_lastWidth, () {
      widget.onSwipeRight?.call();
      setState(() {
        _dragShift = 0.0;
      });
    });
  }

  void _moveLeft() {
    if (_isAnimating || widget.nextData.isEmpty) return;
    widget.onSwipeLeft?.call();
  }

  void _moveRight() {
    if (_isAnimating || widget.previousData.isEmpty) return;
    widget.onSwipeRight?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating || _dragShift.abs() >= _lastWidth) return;
    setState(() {
      _dragShift += details.delta.dx;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAnimating) return;

    const threshold = 50.0;
    if (_dragShift < -threshold) {
      _swipeLeft();
    } else if (_dragShift > threshold) {
      _swipeRight();
    } else {
      _animateTo(0.0, null);
    }
  }

  void _animateTo(double target, VoidCallback? onComplete) {
    _isAnimating = true;
    final animation = Tween<double>(begin: _dragShift, end: target).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    void listener() {
      setState(() {
        _dragShift = animation.value;
      });
    }

    animation.addListener(listener);
    _animationController.forward(from: 0.0).then((_) {
      animation.removeListener(listener);
      _isAnimating = false;
      onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const margin = BarChartPainter.margin;
        _lastWidth = constraints.maxWidth - margin.left - margin.right;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: BarChartPainter(
              currentData: widget.currentData,
              previousData: widget.previousData,
              nextData: widget.nextData,
              shift: _dragShift,
              barColor: widget.barColor,
              textColor: widget.textColor,
              fontSize: widget.fontSize,
            ),
          ),
        );
      },
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<int> currentData;
  final List<int> previousData;
  final List<int> nextData;
  final double shift;
  final Color barColor;
  final Color textColor;
  final double fontSize;
  static const Rect margin = Rect.fromLTRB(50, 20, 50, 20);

  BarChartPainter({
    required this.currentData,
    required this.previousData,
    required this.nextData,
    required this.shift,
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
      ..color = Colors.grey.withAlpha(100)
      ..strokeWidth = 1.0;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final Rect chartRect = Rect.fromLTRB(
      margin.left,
      margin.top,
      size.width - margin.right,
      size.height - margin.bottom,
    );

    final Size chartSize = chartRect.size;
    double mainShift = shift;
    double subShift = 0.0;
    List<int> subData = [];

    if (shift < 0.0) {
      if (nextData.isNotEmpty) {
        subShift = shift + chartSize.width;
        subData = nextData;
      }
    } else if (shift > 0.0) {
      if (previousData.isNotEmpty) {
        subShift = shift - chartSize.width;
        subData = previousData;
      }
    }

    const divisionCount = 48; // 1 division = 0.5 hours
    final totalSpacing = chartSize.width * 0.2;
    final barWidth = (chartSize.width - totalSpacing) / divisionCount;
    final spacing = totalSpacing / (divisionCount + 1);

    final double maxVal = currentData
        .fold(0, (prev, element) => max(prev, element))
        .toDouble();

    final double upperBound = max(50.0, (maxVal / 50.0).ceil() * 50.0);

    final clipPath = Path()
      ..addRect(Rect.fromLTRB(chartRect.left, 0, chartRect.right, size.height));

    canvas.save();
    canvas.clipPath(clipPath);

    // Draw Bars
    if (subData.isNotEmpty) {
      _drawBars(
        canvas: canvas,
        data: subData,
        chartRect: chartRect,
        shift: subShift,
        barWidth: barWidth,
        spacing: spacing,
        barPaint: barPaint,
        upperBound: upperBound,
      );
    }

    _drawBars(
      canvas: canvas,
      data: currentData,
      chartRect: chartRect,
      shift: mainShift,
      barWidth: barWidth,
      spacing: spacing,
      barPaint: barPaint,
      upperBound: upperBound,
    );

    // Draw hour grids and labels
    if (subData.isNotEmpty) {
      _drawGridAndLabels(
        canvas: canvas,
        chartRect: chartRect,
        shift: subShift,
        barWidth: barWidth,
        spacing: spacing,
        axisPaint: axisPaint,
      );
    }

    _drawGridAndLabels(
      canvas: canvas,
      chartRect: chartRect,
      shift: mainShift,
      barWidth: barWidth,
      spacing: spacing,
      axisPaint: axisPaint,
    );

    canvas.restore();

    // Draw static grid lines (Upper and Middle)
    for (final (Offset start, Offset end, Paint paint) in [
      (chartRect.topLeft, chartRect.topRight, gridPaint),
      (chartRect.centerLeft, chartRect.centerRight, gridPaint),
      (chartRect.bottomLeft, chartRect.bottomRight, axisPaint),
    ]) {
      canvas.drawLine(start, end, paint);
    }

    for (final (Offset gridEnd, double value) in [
      (chartRect.topRight, upperBound),
      (chartRect.centerRight, upperBound / 2),
    ]) {
      final label = value.toStringAsFixed(0);
      const gridLabelMargin = Offset(4, 0);
      const alignment = Alignment.centerLeft;
      _drawText(canvas, label, gridEnd + gridLabelMargin, alignment);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Alignment alignment,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset =
        position -
        alignment.alongOffset((Offset.zero & textPainter.size).bottomRight);

    textPainter.paint(canvas, offset);
  }

  void _drawBars({
    required Canvas canvas,
    required List<int> data,
    required Rect chartRect,
    required double shift,
    required double barWidth,
    required double spacing,
    required Paint barPaint,
    required double upperBound,
  }) {
    final barCount = min(48, data.length);
    final chartSize = chartRect.size;
    for (int i = 0; i < barCount; i++) {
      final count = data[i].toDouble();
      final normalizedValue = (count / upperBound).clamp(0.0, 1.0);
      final barHeight = chartSize.height * normalizedValue;
      if (barHeight <= 0) continue;

      final left = chartRect.left + spacing + i * (barWidth + spacing) + shift;
      final top = chartRect.top + chartSize.height - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  void _drawGridAndLabels({
    required Canvas canvas,
    required Rect chartRect,
    required double shift,
    required double barWidth,
    required double spacing,
    required Paint axisPaint,
  }) {
    for (int i = 0; i <= 48; i += 8) {
      final x = chartRect.left + spacing + i * (barWidth + spacing) + shift;
      final top = Offset(x, chartRect.bottom);
      final end = top + const Offset(0, 6);
      final labelTop = top + const Offset(0, 8);
      final labelText = (i / 2).toStringAsFixed(0);
      final alignment = i == 0
          ? Alignment.topLeft
          : i == 48
          ? Alignment.topRight
          : Alignment.topCenter;

      canvas.drawLine(top, end, axisPaint);
      _drawText(canvas, labelText, labelTop, alignment);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return oldDelegate.currentData != currentData ||
        oldDelegate.previousData != previousData ||
        oldDelegate.nextData != nextData ||
        oldDelegate.shift != shift ||
        oldDelegate.barColor != barColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.fontSize != fontSize;
  }
}
