import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as interna;

import '../l10n/app_localizations.dart';

class WeeklyChartViewController {
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
}

class WeeklyChartView extends StatefulWidget {
  final List<int> currentData;
  final List<int> previousData;
  final List<int> nextData;
  final Color barColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final WeeklyChartViewController? controller;

  const WeeklyChartView({
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
  State<WeeklyChartView> createState() => _BarChart();
}

class _BarChart extends State<WeeklyChartView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragShift = 0.0;
  bool _isAnimating = false;
  double _lastWidth = 0.0;
  double _currentUpperBound = 50.0;
  double _previousUpperBound = 50.0;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final maxVal = widget.currentData
        .fold(50, (prev, element) => max(prev, element))
        .toDouble();
    _currentUpperBound = (maxVal / 50.0).ceilToDouble() * 50.0;
    _previousUpperBound = _currentUpperBound;
  }

  @override
  void didUpdateWidget(covariant WeeklyChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }

    if (widget.currentData != oldWidget.currentData) {
      final maxVal = widget.currentData
          .fold(50, (prev, element) => max(prev, element))
          .toDouble();
      final targetUpperBound = (maxVal / 50.0).ceilToDouble() * 50.0;
      if (targetUpperBound == _currentUpperBound) {
        _previousUpperBound = _currentUpperBound;
      } else {
        setState(() {
          _previousUpperBound = _currentUpperBound;
          _currentUpperBound = targetUpperBound;
        });
        _animationController.forward(from: 0.0);
      }
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

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating ||
        _dragShift.abs() >= _lastWidth ||
        (details.delta.dx > 0 && widget.previousData.isEmpty) ||
        (details.delta.dx < 0 && widget.nextData.isEmpty)) {
      return;
    }

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
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const margin = BarChartPainter.margin;
        _lastWidth = constraints.maxWidth - margin.left - margin.right;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              final curve = CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOutCubic,
              );
              final upperBound =
                  _previousUpperBound +
                  (_currentUpperBound - _previousUpperBound) * curve.value;

              return CustomPaint(
                size: const Size(double.infinity, 180),
                painter: BarChartPainter(
                  currentData: widget.currentData,
                  previousData: widget.previousData,
                  nextData: widget.nextData,
                  weekdayLabel: [
                    for (int i = 0; i < 7; ++i)
                      interna.DateFormat.E(
                        l10n.localeName,
                      ).format(DateTime(2026, 9, i)),
                  ],
                  shift: _dragShift,
                  barColor: widget.barColor,
                  textColor: widget.textColor,
                  fontSize: widget.fontSize,
                  tempUpperBound: upperBound,
                  beginUpperBound: _previousUpperBound,
                  endUpperBound: _currentUpperBound,
                ),
              );
            },
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
  final List<String> weekdayLabel;
  final double shift;
  final Color barColor;
  final Color textColor;
  final double fontSize;
  final double tempUpperBound;
  final double beginUpperBound;
  final double endUpperBound;

  static const Rect margin = Rect.fromLTRB(50, 20, 50, 20);

  BarChartPainter({
    required this.currentData,
    required this.previousData,
    required this.nextData,
    required this.weekdayLabel,
    required this.shift,
    required this.barColor,
    required this.textColor,
    required this.fontSize,
    required this.tempUpperBound,
    required this.beginUpperBound,
    required this.endUpperBound,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final proceed =
        (((tempUpperBound - beginUpperBound) /
                        (endUpperBound - beginUpperBound))
                    .clamp(0.0, 1.0) *
                255)
            .toInt();

    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5;

    final gridPaint1 = Paint()
      ..color = Colors.grey.withAlpha(proceed)
      ..strokeWidth = 1.0;

    final gridPaint2 = Paint()
      ..color = Colors.grey.withAlpha(255 - proceed)
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

    final Rect beginCharRect = Rect.fromLTRB(
      chartRect.left,
      chartRect.top +
          chartRect.height *
              (1.0 - beginUpperBound.toDouble() / tempUpperBound.toDouble()),
      chartRect.right,
      chartRect.bottom,
    );

    final Rect endChartRect = Rect.fromLTRB(
      chartRect.left,
      chartRect.top +
          chartRect.height *
              (1.0 - endUpperBound.toDouble() / tempUpperBound.toDouble()),
      chartRect.right,
      chartRect.bottom,
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

    const divisionCount = 7; // 7 days a week
    final totalSpacing = chartSize.width * 0.6;
    final barWidth = (chartSize.width - totalSpacing) / divisionCount;
    final spacing = totalSpacing / divisionCount;

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
        upperBound: tempUpperBound,
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
      upperBound: tempUpperBound,
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
    if (tempUpperBound != endUpperBound) {
      for (final (Offset start, Offset end, Paint paint) in [
        if (beginCharRect.top >= chartRect.top)
          (beginCharRect.topLeft, beginCharRect.topRight, gridPaint2),
        if (beginCharRect.center.dy >= chartRect.top)
          (beginCharRect.centerLeft, beginCharRect.centerRight, gridPaint2),
      ]) {
        canvas.drawLine(start, end, paint);
      }

      for (final (Offset gridEnd, double value) in [
        if (beginCharRect.top >= chartRect.top)
          (beginCharRect.topRight, beginUpperBound),
        if (beginCharRect.center.dy >= chartRect.top)
          (beginCharRect.centerRight, beginUpperBound / 2),
      ]) {
        final label = value.toStringAsFixed(0);
        const gridLabelMargin = Offset(4, 0);
        const alignment = Alignment.centerLeft;
        _drawText(
          canvas,
          label,
          gridEnd + gridLabelMargin,
          alignment,
          proceed: 255 - proceed,
        );
      }
    }

    for (final (Offset start, Offset end, Paint paint) in [
      if (endChartRect.top >= chartRect.top)
        (endChartRect.topLeft, endChartRect.topRight, gridPaint1),
      if (endChartRect.center.dy >= chartRect.top)
        (endChartRect.centerLeft, endChartRect.centerRight, gridPaint1),
      (endChartRect.bottomLeft, endChartRect.bottomRight, axisPaint),
    ]) {
      canvas.drawLine(start, end, paint);
    }

    for (final (Offset gridEnd, double value) in [
      if (endChartRect.top >= chartRect.top)
        (endChartRect.topRight, endUpperBound),
      if (endChartRect.center.dy >= chartRect.top)
        (endChartRect.centerRight, endUpperBound / 2),
    ]) {
      final label = value.toStringAsFixed(0);
      const gridLabelMargin = Offset(4, 0);
      const alignment = Alignment.centerLeft;
      _drawText(
        canvas,
        label,
        gridEnd + gridLabelMargin,
        alignment,
        proceed: proceed,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Alignment alignment, {
    int proceed = 255,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor.withAlpha(proceed),
          fontSize: fontSize,
        ),
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
    final barCount = min(7, data.length);
    final chartHeight = chartRect.size.height;
    final origin =
        chartRect.bottomLeft + Offset(spacing - barWidth / 2 + shift, 0);
    for (int i = 0; i < barCount; i++) {
      final count = data[i];
      if (count <= 0) continue;

      final normalizedValue = (count.toDouble() / upperBound).clamp(0.0, 1.0);
      final barHeight = chartHeight * normalizedValue;
      final left = origin.dx + i * (barWidth + spacing);
      final top = origin.dy - barHeight;

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
    final origin = chartRect.bottomLeft + Offset(spacing + shift, 0);
    for (int i = 0; i < 7; ++i) {
      final top = origin + Offset(i * (barWidth + spacing), 0);
      final end = top + const Offset(0, 4);
      final labelTop = top + const Offset(0, 20);
      final labelText = weekdayLabel[i];
      canvas.drawLine(top, end, axisPaint);
      _drawText(canvas, labelText, labelTop, Alignment.bottomCenter);
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
        oldDelegate.fontSize != fontSize ||
        oldDelegate.tempUpperBound != tempUpperBound ||
        oldDelegate.beginUpperBound != beginUpperBound ||
        oldDelegate.endUpperBound != endUpperBound;
  }
}
