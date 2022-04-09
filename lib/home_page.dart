import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:race_chart/race_chart_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  Animation<double>? _animation;
  var data = <List<ChartData>>[];

  @override
  void initState() {
    super.initState();
    _loadCsvData().then((value) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 80),
      );
      _animation = Tween(begin: 0.0, end: 19.0).animate(_controller!);

      _controller!.forward();

      _controller!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller!.repeat();
        } else if (status == AnimationStatus.dismissed) {
          _controller!.forward();
        }
      });
    });
  }

  Future<void> _loadCsvData() async {
    final csvFile = await rootBundle.loadString("assets/brands_history.csv");
    final fields = csvFile.split('\n');
    fields.removeAt(0);

    final data = <String, List<ChartData>>{};
    final brandColors = <String, Color>{};

    for (final field in fields) {
      if (field.isEmpty) {
        continue;
      }

      final values = field.split(',');

      final date = values[0];
      final brand = values[1];
      final category = values[2];
      final valueToDouble = values[3];
      final value = int.parse(valueToDouble);

      if (brandColors[brand] == null) {
        brandColors[brand] =
            Colors.primaries[Random().nextInt(Colors.primaries.length)];
      }

      final dataParsed = ChartData(
        date,
        brand,
        category,
        value.toDouble(),
        brandColors[brand]!,
      );

      if (data[date] == null) {
        data[date] = [dataParsed];
      } else {
        data[date]!.add(dataParsed);
      }
    }

    setState(() {
      this.data = data.values.map((e) => e).toList();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: _animation == null
            ? const SizedBox.shrink()
            : AnimatedBuilder(
                animation: _animation!,
                builder: (context, _) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CustomPaint(
                      size: Size(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height,
                      ),
                      painter:
                          RaceChartPainter(data: data, animation: _animation!),
                    ),
                  );
                }));
  }
}
