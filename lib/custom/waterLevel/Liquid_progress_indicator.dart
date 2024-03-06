import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:run_tracker/utils/Color.dart';

import 'Wave_man.dart';

const double _twoPi = math.pi * 2.0;
const double _epsilon = .001;
const double _sweep = _twoPi - _epsilon;

class LiquidCircularProgressIndicator extends ProgressIndicator {
  final double? borderWidth;

  final Color? borderColor;

  final Widget? center;

  final Axis direction;

  LiquidCircularProgressIndicator({
    Key? key,
    double value = 0.5,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    this.borderWidth,
    this.borderColor,
    this.center,
    this.direction = Axis.vertical,
  }) : super(
    key: key,
    value: value,
    backgroundColor: backgroundColor,
    valueColor: valueColor,
  ) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).colorScheme.background;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).colorScheme.secondary;

  @override
  State<StatefulWidget> createState() =>
      _LiquidCircularProgressIndicatorState();
}

class _LiquidCircularProgressIndicatorState
    extends State<LiquidCircularProgressIndicator> {


  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CircleClipper(),
      child: CustomPaint(
        painter: _CirclePainter(
          color: widget._getBackgroundColor(context),
        ),
        foregroundPainter: _CircleBorderPainter(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        child: Stack(
          children: [
            Wave(
              value: widget.value,
              color: widget._getValueColor(context),
              direction: widget.direction,
              time: 2,
            ),
            Wave(
              value: widget.value,
              color: Colur.water_level_wave1,
              direction: widget.direction,
              time: 3,
            ),
            if (widget.center != null) Center(child: widget.center),
          ],
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;

  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawArc(Offset.zero & size, 0, _sweep, false, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => color != oldDelegate.color;
}

class _CircleBorderPainter extends CustomPainter {
  final Color? color;
  final double? width;

  _CircleBorderPainter({this.color, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || width == null) {
      return;
    }

    final borderPaint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;
    final newSize = Size(size.width - width!, size.height - width!);
    canvas.drawArc(
        Offset(width! / 2, width! / 2) & newSize, 0, _sweep, false, borderPaint);
  }

  @override
  bool shouldRepaint(_CircleBorderPainter oldDelegate) =>
      color != oldDelegate.color || width != oldDelegate.width;
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..addArc(Offset.zero & size, 0, _sweep);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
