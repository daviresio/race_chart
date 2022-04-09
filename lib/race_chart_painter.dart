import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:race_chart/helpers/format_helper.dart';

class RaceChartPainter extends CustomPainter {
  final List<List<ChartData>> data;
  final Animation<double> animation;

  RaceChartPainter({required this.data, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const barHeight = 32.0;
    const barPadding = 10.0;
    const barSize = barHeight + barPadding;

    final higherValue = data
        .map((list) => list.map((data) => data.value).reduce(math.max))
        .reduce(math.max);

    final index = animation.value.floor();

    final dataList = data[index];

    for (var i = 0; i < dataList.length; i++) {
      final currentData = dataList[i];

      final nextListIndex = index + 1 >= data.length ? index : index + 1;

      final currentList = [...dataList];
      final nexList = [...data[nextListIndex]];
      currentList.sort((a, b) => b.value.compareTo(a.value));
      nexList.sort((a, b) => b.value.compareTo(a.value));

      var nextIndex =
          nexList.indexWhere((element) => element.brand == currentData.brand);

      if (nextIndex == -1) {
        nextIndex = i;
      }

      final remapedValue = remap(
        animation.value,
        animation.value.floor().toDouble(),
        animation.value.ceil().toDouble(),
        currentList[i].value,
        nexList[nextIndex].value,
      );

      final indexRemapped = remap(
        animation.value,
        animation.value.floor().toDouble(),
        animation.value.ceil().toDouble(),
        i.toDouble(),
        nextIndex.toDouble(),
      );

      final startY = barSize * indexRemapped;
      final endY = startY + barHeight;
      const startX = -3.0;
      final endX =
          remap(remapedValue, 0, higherValue.toDouble(), 0, size.width - 120);

      final rect = RRect.fromLTRBR(
          startX, startY, endX, endY, const Radius.circular(5.0));
      paint.style = PaintingStyle.fill;
      paint.color = currentData.color.withOpacity(0.4);

      canvas.drawRRect(rect, paint);

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      paint.color = currentData.color;
      canvas.drawRRect(rect, paint);

      final textBrand = TextSpan(
        text: currentData.brand,
        style: const TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600),
      );

      final painterBrand = _getTextPainter(textBrand);
      painterBrand.paint(canvas, Offset(endX - painterBrand.width - 5, startY));

      final valueRemapped = remap(
        animation.value,
        animation.value.floor().toDouble(),
        animation.value.ceil().toDouble(),
        currentData.value,
        data[nextListIndex][i].value,
      );

      final textValue = TextSpan(
        text: moneyNoCents(valueRemapped),
        style: TextStyle(
          color: Colors.black.withOpacity(0.65),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

      final painterValue = _getTextPainter(textValue);
      painterValue.paint(
        canvas,
        Offset(endX + 5, startY + 5),
      );
    }

    final textYear = TextSpan(
      text: dataList.first.date.split('-').first,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
    );

    final painterYear = _getTextPainter(textYear);
    painterYear.paint(
        canvas,
        Offset(
          size.width - painterYear.width - 100,
          size.height - painterYear.height - 60,
        ));
  }

  @override
  bool shouldRepaint(covariant RaceChartPainter oldDelegate) {
    return true;
  }

  TextPainter _getTextPainter(TextSpan text) {
    final textPainter = TextPainter(
      text: text,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    return textPainter;
  }
}

class ChartData {
  final String date;
  final String brand;
  final String category;
  final double value;
  final Color color;

  ChartData(this.date, this.brand, this.category, this.value, this.color);
}

double remap(
  double value,
  double start1,
  double stop1,
  double start2,
  double stop2,
) {
  final outgoing =
      start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));

  return outgoing;
}
