import 'dart:math';

import 'package:charts_flutter_new/flutter.dart';

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  static String? value;

  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      Color? fillColor,
      FillPatternType? fillPattern,
      Color? strokeColor,
      double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    canvas.drawRRect(
      Rectangle(bounds.left-8, bounds.top - 30, bounds.width + 30,
          bounds.height + 10),
      fill: Color.fromOther(color: Color(r: 134, b: 173, g: 138)),
      radius: 10,
      roundTopLeft: true,
      roundTopRight: true,
      roundBottomLeft: true,
      roundBottomRight: true,
    );

    TextElement textElement =
        canvas.graphicsFactory.createTextElement("$value");

    canvas.drawText(
        textElement, (bounds.left+5).round(), (bounds.top - 24).round());
  }
}
