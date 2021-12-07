import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
class CountPage extends StatefulWidget {
  CountPage({Key? key}) : super(key: key);

  _CountPageState createState() => _CountPageState();
}


class PopulationData {
  int year;
  int population;
  charts.Color barColor;
  PopulationData({
    required this.year, 
    required this.population,
    required this.barColor
  });
}

@override

class _CountPageState extends State<CountPage> {
  @override
  Widget build(BuildContext context) {
    return Text("統計");
  }
}
