import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:doto_app/model/chartJsonData.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class CountPage extends StatefulWidget {
  CountPage({
    Key? key,
  }) : super(key: key);
  @override
  _CountPage createState() => _CountPage();
}

class PieChart {
  String events;
  int times;

  PieChart({required this.events, required this.times});
  @override
  factory PieChart.fromJson(Map<String, dynamic> json) => PieChart(
        events: json["events"],
        times: json["times"],
      );

  Map<String, dynamic> toJson() => {
        "events": events,
        "times": times,
      };
}

class SalesData {
  final int month;
  final int time;

  SalesData(this.month, this.time);
}

class PopulationData {
  int year;
  int population;
  charts.Color barColor;
  PopulationData(
      {required this.year, required this.population, required this.barColor});
}

enum setdate { date, month, week }

class _CountPage extends State<CountPage> {
  String hasdate = ""; //日付表示
  String hasdate2 = "";

  var selectdate = setdate.date;

  final List<PopulationData> data = [
    PopulationData(
        year: 1880,
        population: 50189209,
        barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)),
    PopulationData(
        year: 1890,
        population: 62979766,
        barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)),
    PopulationData(
        year: 1900,
        population: 76212168,
        barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)),
    PopulationData(
        year: 1910,
        population: 92228496,
        barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)),
    PopulationData(
        year: 1920,
        population: 106021537,
        barColor: charts.ColorUtil.fromDartColor(Colors.blue)),
    PopulationData(
        year: 1930,
        population: 123202624,
        barColor: charts.ColorUtil.fromDartColor(Colors.blue)),
    PopulationData(
        year: 1940,
        population: 132164569,
        barColor: charts.ColorUtil.fromDartColor(Colors.blue)),
    PopulationData(
        year: 1950,
        population: 151325798,
        barColor: charts.ColorUtil.fromDartColor(Colors.blue)),
    PopulationData(
        year: 1960,
        population: 179323175,
        barColor: charts.ColorUtil.fromDartColor(Colors.blue)),
    PopulationData(
        year: 1970,
        population: 203302031,
        barColor: charts.ColorUtil.fromDartColor(Colors.purple)),
    PopulationData(
        year: 1980,
        population: 226542199,
        barColor: charts.ColorUtil.fromDartColor(Colors.purple)),
    PopulationData(
        year: 1990,
        population: 248709873,
        barColor: charts.ColorUtil.fromDartColor(Colors.purple)),
    PopulationData(
        year: 2000,
        population: 281421906,
        barColor: charts.ColorUtil.fromDartColor(Colors.purple)),
    PopulationData(
        year: 2010,
        population: 307745538,
        barColor: charts.ColorUtil.fromDartColor(Colors.black)),
    PopulationData(
        year: 2017,
        population: 323148586,
        barColor: charts.ColorUtil.fromDartColor(Colors.black)),
  ];

  // final List<GradesData> data2 = [
  //   GradesData('項目名', 190),
  //   GradesData('B', 230),
  //   GradesData('C', 150),
  //   GradesData('D', 73),
  //   GradesData('E', 31),
  //   GradesData('Fail', 13),
  // ];

  List<Contents> dashboardResult = [];
  List<ChartJsonData> chartJsonData = [];
  List perTimes = [];
  List data2 = [];
  @override
  void initState() {
    super.initState();
    hasdate = formatDate(DateTime.now(), [
      'yyyy',
      "-",
      'mm',
      "-",
      'dd',
    ]).toString();
    //饼状图用分钟数来表示每天的数据记录
    String jsonString = ''' 
           [ {
"date":"2021-12-26",
 "contents":[{"events":"看书","times":50},{"events":"扔垃圾","times":50}] 
             },
  {"date":"2021-12-27",
              "contents":[{"events":"买菜","times":20},{"events":"吃饭","times":45}] 
             },
  {"date":"2021-12-28",
              "contents":[{"events":"睡觉","times":10},{"events":"上厕所","times":1}] 
             }]''';
    data2 = json.decode(jsonString);
    data2.forEach((e) {
      chartJsonData.add(ChartJsonData.fromJson(e));
    });
    chartJsonData.forEach((element) {
      element.contents.forEach((element) {
        perTimes.add(element.times);
        dashboardResult.add(element);
      });
    });
    // data2.forEach((e) {
    //   dashboardResult.add(PieChart.fromJson(e));
    // });
    // print(dashboardResult);
  }

  dataChange() {
    Int times;
    chartJsonData.forEach((element) {
      element.contents.forEach((element) {});
    });
  }

  _getData() {
    List<charts.Series<Contents, String>> series = [
      charts.Series(
          id: "Grades",
          data: dashboardResult,
          labelAccessorFn: (Contents row, _) => '${row.times}分',
          domainFn: (Contents grades, _) => grades.events,
          measureFn: (Contents grades, _) => grades.times)
    ];
    return series;
  }

  _getSeriesData() {
    List<charts.Series<PopulationData, String>> series = [
      charts.Series(
          id: "Population",
          data: data,
          domainFn: (PopulationData series, _) => series.year.toString(),
          measureFn: (PopulationData series, _) => series.population,
          colorFn: (PopulationData series, _) => series.barColor)
    ];
    return series;
  }

  final data1 = [
    new SalesData(1, 1500000),
    new SalesData(2, 1735000),
    new SalesData(3, 1678000),
    new SalesData(4, 1890000),
    new SalesData(5, 1907000),
    new SalesData(6, 2300000),
    new SalesData(7, 2360000),
    new SalesData(8, 1980000),
    new SalesData(9, 2654000),
    new SalesData(10, 2789070),
    new SalesData(11, 2789070),
    new SalesData(12, 2789070),
  ];

  _getSeries() {
    List<charts.Series<SalesData, int>> series = [
      charts.Series(
          id: "Sales",
          data: data1,
          domainFn: (SalesData series, _) => series.month,
          measureFn: (SalesData series, _) => series.time,
          colorFn: (SalesData series, _) =>
              charts.MaterialPalette.blue.shadeDefault)
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          //title: Text(_strTitle, style: TextStyle(color: commonStrColor)), //AIForce Equipment App
          title: Text('統計'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                // Container(
                //   height: 400,
                //   padding: EdgeInsets.all(20),
                //   child: Card(
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Column(
                //         children: <Widget>[
                //           Text(
                //             "タイトル",
                //             style: TextStyle(fontWeight: FontWeight.bold),
                //           ),
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Expanded(
                //             child: charts.BarChart(
                //               _getSeriesData(),
                //               animate: true,
                //               domainAxis: charts.OrdinalAxisSpec(
                //                   renderSpec: charts.SmallTickRendererSpec(
                //                       labelRotation: 60)),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Container(
                //   height: 400,
                //   padding: EdgeInsets.all(20),
                //   child: Card(
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Column(
                //         children: <Widget>[
                //           Text(
                //             "タイトル",
                //             style: TextStyle(fontWeight: FontWeight.bold),
                //           ),
                //           SizedBox(
                //             height: 20,
                //           ),
                //           Expanded(
                //             child: new charts.LineChart(
                //               _getSeries(),
                //               animate: true,
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  height: 80,
                  child: Card(
                      child: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          Text(
                            "累計時間",
                            style: TextStyle(
                                fontSize: 18.0,
                                // fontStyle: FontStyle.italic,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text("889.5時間"),
                        ]),
                        Column(children: [
                          Text(
                            "日平均時間",
                            style: TextStyle(
                                fontSize: 18.0,
                                // fontStyle: FontStyle.italic,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text("2.5時間"),
                        ]),
                        Column(children: [
                          Text(
                            "予定より",
                            style: TextStyle(
                                fontSize: 18.0,
                                // fontStyle: FontStyle.italic,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text("2.15時間早い"),
                        ])
                      ],
                    ),
                  )),
                ),
                Container(
                    child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("総時間表示"),
                        IconButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              changedate(selectdate, "back");
                            },
                            icon: Icon(Icons.arrow_back_ios_rounded)),
                        Text(selectdate == setdate.date
                            ? hasdate
                            : hasdate + ' ~ ' + hasdate2),
                        IconButton(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              changedate(selectdate, "forward");
                            },
                            icon: Icon(Icons.arrow_forward_ios_rounded)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlineButton(
                            hoverColor: Colors.white,
                            autofocus: true,
                            highlightColor: Colors.pink,
                            onPressed: () {
                              selectdate = setdate.date;
                            },
                            child: Text("日")),
                        OutlineButton(
                            hoverColor: Colors.white,
                            highlightColor: Colors.pink,
                            onPressed: () {
                              selectdate = setdate.month;
                              var usedate = hasdate == ""
                                  ? new DateTime.now()
                                  : DateTime.parse(hasdate);
                              var changeddate =
                                  new DateTime(usedate.year, usedate.month, 01);
                              var changeddate2 = new DateTime(
                                  changeddate.year, changeddate.month + 1, 01);
                              hasdate = formatDate(changeddate, [
                                'yyyy',
                                "-",
                                'mm',
                                "-",
                                'dd',
                              ]).toString();
                              hasdate2 = formatDate(changeddate2, [
                                'yyyy',
                                "-",
                                'mm',
                                "-",
                                'dd',
                              ]).toString();
                              setState(() {});
                            },
                            child: Text("月")),
                        OutlineButton(
                            hoverColor: Colors.white,
                            highlightColor: Colors.pink,
                            onPressed: () {
                              selectdate = setdate.week;
                              var usedate = hasdate == ""
                                  ? new DateTime.now()
                                  : DateTime.parse(hasdate);
                              var _firstDayOfTheweek = usedate.subtract(
                                  new Duration(days: usedate.weekday - 1));
                              var changeddate = new DateTime(usedate.year,
                                  usedate.month, _firstDayOfTheweek.day);

                              var changeddate2 = new DateTime(changeddate.year,
                                  changeddate.month, changeddate.day + 06);
                              print(_firstDayOfTheweek.day);
                              hasdate = formatDate(changeddate, [
                                'yyyy',
                                "-",
                                'mm',
                                "-",
                                'dd',
                              ]).toString();
                              hasdate2 = formatDate(changeddate2, [
                                'yyyy',
                                "-",
                                'mm',
                                "-",
                                'dd',
                              ]).toString();
                              setState(() {});
                            },
                            child: Text("週")),
                      ],
                    )
                  ],
                )),
                Container(
                  height: 400,
                  padding: EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "円グラフ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: new charts.PieChart(
                              _getData(),
                              animate: true,
                              defaultInteractions: true,
                              defaultRenderer: new charts.ArcRendererConfig(
                                //arcWidth: 40,
                                arcRendererDecorators: [
                                  new charts.ArcLabelDecorator(
                                    labelPosition: charts.ArcLabelPosition.auto,
                                    //labelPadding : 1
                                  )
                                ],
                              ),
                              selectionModels: [
                                new charts.SelectionModelConfig(
                                    type: charts.SelectionModelType.info,
                                    changedListener: _onSelectionChanged,
                                    updatedListener: _onSelectionUpdated),
                                new charts.SelectionModelConfig(
                                    type: charts.SelectionModelType.action,
                                    changedListener: _onSelectionChanged,
                                    updatedListener: _onSelectionUpdated),
                              ],
                              behaviors: [
                                new charts.DatumLegend(
                                  // Positions for "start" and "end" will be left and right respectively
                                  // for widgets with a build context that has directionality ltr.
                                  // For rtl, "start" and "end" will be right and left respectively.
                                  // Since this example has directionality of ltr, the legend is
                                  // positioned on the right side of the chart.
                                  position: charts.BehaviorPosition.bottom,
                                  // By default, if the position of the chart is on the left or right of
                                  // the chart, [horizontalFirst] is set to false. This means that the
                                  // legend entries will grow as new rows first instead of a new column.
                                  horizontalFirst: true,
                                  desiredMaxRows: 5,
                                  desiredMaxColumns: 3,
                                  //cellPadding:EdgeInsets.all(10),
                                  // Set [showMeasures] to true to display measures in series legend.
                                  showMeasures: true,
                                  entryTextStyle: charts.TextStyleSpec(
                                      color: charts
                                          .MaterialPalette.red.shadeDefault,
                                      fontFamily: 'Georgia',
                                      fontSize: 13),
                                ),
                                // Configure the measure value to be shown by default in the legend.
                                // legendDefaultMeasure:
                                //     charts.LegendDefaultMeasure.firstValue,
                                // Optionally provide a measure formatter to format the measure value.
                                // If none is specified the value is formatted as a decimal.
                                // measureFormatter: (num value) {
                                //   return value == null ? '-' : '${value}k';
                                // },
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  changedate(setdate getdate, String button) {
    //先传入时间，判断是月日周
    //再传入按键是前还是后
    //根据初始时间调用并返回相应的时间

    var usedate = hasdate == "" ? new DateTime.now() : DateTime.parse(hasdate);
    if (button == "back") {
      switch (getdate) {
        case setdate.date:
          var changeddate = usedate.subtract(Duration(days: 1));
          hasdate = formatDate(changeddate, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          break;
        case setdate.month:
          //2021-12-01~2022-01-01
          var changeddate = new DateTime(usedate.year, usedate.month - 1, 01);
          print(changeddate);
          var changeddate2 =
              new DateTime(changeddate.year, changeddate.month + 1, 01);
          hasdate = formatDate(changeddate, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          hasdate2 = formatDate(changeddate2, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          break;
        case setdate.week:
          //2021-12-20~2022-12-26

          var _firstDayOfTheweek =
              usedate.subtract(new Duration(days: usedate.weekday - 1));
          var changeddate = new DateTime(
              usedate.year, usedate.month, _firstDayOfTheweek.day - 7);

          var changeddate2 = new DateTime(
              changeddate.year, changeddate.month, changeddate.day + 6);
          print(_firstDayOfTheweek.day);
          hasdate = formatDate(changeddate, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          hasdate2 = formatDate(changeddate2, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          break;
      }
    } else if (button == "forward") {
      switch (getdate) {
        case setdate.date:
          var changeddate = usedate.add(Duration(days: 1));
          print(changeddate);
          hasdate = formatDate(changeddate, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          break;
        case setdate.month:
          var changeddate = new DateTime(usedate.year, usedate.month + 1, 01);
          var changeddate2 =
              new DateTime(changeddate.year, changeddate.month + 1, 01);
          hasdate = formatDate(changeddate, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          hasdate2 = formatDate(changeddate2, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          break;
        case setdate.week:
          var _firstDayOfTheweek =
              usedate.subtract(new Duration(days: usedate.weekday - 1));
          var changeddate = new DateTime(
              usedate.year, usedate.month, _firstDayOfTheweek.day + 7);

          var changeddate2 = new DateTime(
              changeddate.year, changeddate.month, changeddate.day + 6);
          print(_firstDayOfTheweek.day);
          hasdate = formatDate(changeddate, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
          hasdate2 = formatDate(changeddate2, [
            'yyyy',
            "-",
            'mm',
            "-",
            'dd',
          ]).toString();
      }
    }
    setState(() {});
  }

  _onSelectionChanged(charts.SelectionModel model) {
    print('In _onSelectionChanged');
    final selectedDatum = model.selectedDatum;
    // print(selectedDatum.length);
    if (selectedDatum.first.datum) {
      //print(model.selectedSeries[0].measureFn(model.selectedDatum[0].index));
      //chartAmountText = selectedDatum[0].datum.totalSpend.toString().split('.');
    }
  }

  _onSelectionUpdated(charts.SelectionModel model) {
    // print('In _onSelectionUpdated');
    // if (selectedDatum.length > 0) {
    //   print(selectedDatum[0].datum.category);
    // }
  }
}
