import 'dart:math' as math;

import 'package:flutter/material.dart';

class RaceChartPainter extends CustomPainter {
  final List<List<ChartData>> data;
  final Animation<double> animation;

  RaceChartPainter({required this.data, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final higherValue = data
        .map((list) => list.map((data) => data.value).reduce(math.max))
        .reduce(math.max);

    const barHeight = 30.0;
    const barPadding = 10.0;
    const barSize = barHeight + barPadding;

    final index = animation.value.floor();

    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    final dataList = data[index];

    // canvas.drawRect(
    //   Rect.fromLTWH(0, 0, size.width, size.height),
    //   Paint()..color = Colors.green.withOpacity(0.1),
    // );

    for (var i = 0; i < dataList.length; i++) {
      double? remapedValue;

      final newList1 = [...dataList];
      final newList2 = [...data[index + 1]];
      newList1.sort((a, b) => b.value.compareTo(a.value));
      newList2.sort((a, b) => b.value.compareTo(a.value));
      final index1 =
          newList1.indexWhere((element) => element.brand == dataList[i].brand);
      var index2 =
          newList2.indexWhere((element) => element.brand == dataList[i].brand);

      if (index2 == -1) {
        index2 = index1;
      }

      try {
        if (index + 1 <= data.length - 1) {
          remapedValue = remap(
            animation.value,
            animation.value.floor().toDouble(),
            animation.value.ceil().toDouble(),
            newList1[index1].value,
            newList2[index2].value,
          );
        }
      } catch (e) {
        print(e);
      }

      final floor = animation.value.floor().toDouble();

      final ceil = animation.value.ceil().toDouble();

      final indexRemapped = remap(
        animation.value,
        animation.value.floor().toDouble(),
        animation.value.ceil().toDouble(),
        index1.toDouble(),
        index2.toDouble(),
      );

      final startY = barSize * indexRemapped;
      final endY = startY + barHeight;
      const startX = 0.0;

      final endX = remap(
          (remapedValue == null || remapedValue.isNaN)
              ? dataList[i].value
              : remapedValue,
          0,
          higherValue.toDouble(),
          0,
          size.width);

      final rect = Rect.fromLTRB(startX, startY, endX, endY);

      canvas.drawRect(rect, paint);

      final TextSpan span = TextSpan(
          text: dataList[i].brand,
          style: const TextStyle(color: Colors.redAccent, fontSize: 30));

      final textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(endX, startY));
    }

    final TextSpan span = TextSpan(
      text: dataList.first.date.split('-').first,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.8, size.height * 0.8));
  }

  @override
  bool shouldRepaint(covariant RaceChartPainter oldDelegate) {
    return true;
    // return oldDelegate.animation.value != animation.value;
  }
}

class ChartData {
  final String date;
  final String brand;
  final String category;
  final double value;

  ChartData(this.date, this.brand, this.category, this.value);
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
