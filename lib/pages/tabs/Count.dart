import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:doto_app/model/chartJsonData.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

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
  bool visible = false;
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
  List data2 = [];
  int times = 0;
  int totalTimes = 0;
  int selectedTotalTimes = 0;
  Color onSelected = Colors.black87;
  Color onSelected2 = Colors.black87;
  Color onSelected3 = Colors.black87;
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
 "contents":[{"events":"読書","times":280},{"events":"ごみ捨て","times":1000000},{"events":"ごみ捨て","times":1000}] 
             },
  {"date":"2021-12-27",
              "contents":[{"events":"買い物","times":80},{"events":"ご飯食べる","times":150},{"events":"野菜","times":1050},{"events":"遊び","times":150}] 
             },
  {"date":"2021-12-28",
              "contents":[{"events":"ねる","times":500},{"events":"トイレ","times":105},{"events":"お野菜","times":105}] 
             },
             {"date":"2021-11-28",
              "contents":[{"events":"11月","times":500},{"events":"トイレ","times":105},{"events":"お野菜","times":105}] 
             },
             {"date":"2021-10-28",
              "contents":[{"events":"10月","times":500},{"events":"トイレ","times":105},{"events":"お野菜","times":105}] 
             },
             {"date":"2021-10-01",
              "contents":[{"events":"10月01","times":500},{"events":"测试3","times":105},{"events":"努力测试3","times":105}] 
             },
              {"date":"2021-10-25",
              "contents":[{"events":"10月25","times":500},{"events":"测试","times":105},{"events":"努力测试","times":105}] 
             },
             {"date":"2021-10-31",
              "contents":[{"events":"10月31","times":500},{"events":"测试1","times":105},{"events":"努力测试1","times":105}] 
             },
             {"date":"2021-11-01",
              "contents":[{"events":"11月1","times":500},{"events":"测试11","times":105},{"events":"努力测试11","times":105}] 
             }]''';
    data2 = json.decode(jsonString);
    data2.forEach((e) {
      chartJsonData.add(ChartJsonData.fromJson(e));
    });
    chartJsonData.forEach((element) {
      element.contents.forEach((e) {
        totalTimes = totalTimes + e.times;
      });
    });
    gettimes();
    dataChange();
  }

  gettimes() {
    if (hasdate2 == "") {
      chartJsonData.forEach((element) {
        element.contents.forEach((e) {
          if (hasdate == element.date) {
            times = times == 0 ? e.times : times + e.times;
          }
        });
      });
    } else {
      var dateAdjustment = DateTime.parse(hasdate).subtract(Duration(days: 1));
      var dateAdjustment2 = DateTime.parse(hasdate2).add(Duration(days: 1));
      chartJsonData.forEach((element) {
        element.contents.forEach((e) {
          if (dateAdjustment.isBefore(DateTime.parse(element.date)) &&
              dateAdjustment2.isAfter(DateTime.parse(element.date))) {
            times = times == 0 ? e.times : times + e.times;
          }
        });
      });
    }
  }

  String constructTime(int seconds, {bool time = false}) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    if (hour == 0) {
      if (time) {
        return formatTime(minute) + ":" + formatTime(second);
      }
      return formatTime(minute) + "分" + formatTime(second) + "秒";
    } else {
      if (time) {
        return formatTime(hour) +
            ":" +
            formatTime(minute) +
            ":" +
            formatTime(second);
      }
      return formatTime(hour) +
          "時間" +
          formatTime(minute) +
          "分" +
          formatTime(second) +
          "秒";
    }
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  dataChange() {
    int percent = 0;
    chartJsonData.forEach((element) {
      if (hasdate2 == "") {
        element.contents.forEach((e) {
          if (hasdate == element.date) {
            percent = ((e.times / times) * 100).round();
            selectedTotalTimes = selectedTotalTimes + e.times;
            dashboardResult.add(
                Contents(times: e.times, events: e.events, percent: percent));
          }
        });
      } else {
        element.contents.forEach((e) {
          var dateAdjustment =
              DateTime.parse(hasdate).subtract(Duration(days: 1));
          var dateAdjustment2 = DateTime.parse(hasdate2).add(Duration(days: 1));
          if (dateAdjustment.isBefore(DateTime.parse(element.date)) &&
              dateAdjustment2.isAfter(DateTime.parse(element.date))) {
            selectedTotalTimes = selectedTotalTimes + e.times;
            percent = ((e.times / times) * 100).round();
            dashboardResult.add(
                Contents(times: e.times, events: e.events, percent: percent));
          }
        });
      }
    });
    dashboardResult.isEmpty ? visible = false : visible = true;
  }

  _getData() {
    List<charts.Series<Contents, String>> series = [
      charts.Series(
          id: "Grades",
          data: dashboardResult,
          labelAccessorFn: (Contents row, _) => '${row.times}分',
          domainFn: (Contents grades, _) => grades.events,
          measureFn: (Contents grades, _) => grades.percent)
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
                Container(
                  height: 80,
                  width: 600,
                  child: Card(
                      child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "累計総時間:",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.pink,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 20),
                                Text("${constructTime(totalTimes)}"),

                                //   Column(children: [
                                //     Text(
                                //       "平均",
                                //       style: TextStyle(
                                //           fontSize: 18.0,
                                //           // fontStyle: FontStyle.italic,
                                //           color: Colors.pink,
                                //           fontWeight: FontWeight.bold),
                                //     ),
                                //     SizedBox(
                                //       height: 5,
                                //     ),
                                //     Text("2.5時間"),
                                //   ]),
                                //   Column(children: [
                                //     Text(
                                //       "本日",
                                //       style: TextStyle(
                                //           fontSize: 18.0,
                                //           // fontStyle: FontStyle.italic,
                                //           color: Colors.pink,
                                //           fontWeight: FontWeight.bold),
                                //     ),
                                //     SizedBox(
                                //       height: 5,
                                //     ),
                                //     Text("2.15時間早い"),
                                //   ])
                              ],
                            ),
                          ))),
                ),
                Container(
                    height: 550,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      changedate(selectdate, "back");
                                      //times = 0;
                                      dashboardResult = [];
                                      selectedTotalTimes = 0;
                                      gettimes();
                                      dataChange();
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
                                      //times = 0;
                                      dashboardResult = [];
                                      selectedTotalTimes = 0;
                                      gettimes();
                                      dataChange();
                                    },
                                    icon:
                                        Icon(Icons.arrow_forward_ios_rounded)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlineButton(
                                    textColor: onSelected,
                                    onPressed: () {
                                      onSelected = Colors.pink;
                                      onSelected2 = Colors.black87;
                                      onSelected3 = Colors.black87;
                                      setState(() {
                                        selectdate = setdate.date;
                                        hasdate2 = "";
                                        var usedate = new DateTime.now();
                                        hasdate = formatDate(usedate, [
                                          'yyyy',
                                          "-",
                                          'mm',
                                          "-",
                                          'dd',
                                        ]).toString();
                                        dashboardResult = [];
                                        gettimes();
                                        dataChange();
                                      });
                                    },
                                    child: Text("日")),
                                OutlineButton(
                                    textColor: onSelected2,
                                    onPressed: () {
                                      onSelected2 = Colors.pink;
                                      onSelected = Colors.black87;
                                      onSelected3 = Colors.black87;
                                      selectdate = setdate.month;
                                      var usedate = hasdate == ""
                                          ? new DateTime.now()
                                          : DateTime.parse(hasdate);
                                      var changeddate = new DateTime(
                                          usedate.year, usedate.month, 01);
                                      var changeddate2 = new DateTime(
                                          changeddate.year,
                                          changeddate.month + 1,
                                          01);
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
                                      dashboardResult = [];
                                      gettimes();
                                      dataChange();
                                      setState(() {});
                                    },
                                    child: Text("月")),
                                OutlineButton(
                                    textColor: onSelected3,
                                    onPressed: () {
                                      onSelected3 = Colors.pink;
                                      onSelected2 = Colors.black87;
                                      onSelected = Colors.black87;
                                      selectdate = setdate.week;
                                      var usedate = new DateTime.now();
                                      var _firstDayOfTheweek = usedate.subtract(
                                          new Duration(
                                              days: usedate.weekday - 1));
                                      var changeddate = new DateTime(
                                          usedate.year,
                                          usedate.month,
                                          _firstDayOfTheweek.day);

                                      var changeddate2 = new DateTime(
                                          changeddate.year,
                                          changeddate.month,
                                          changeddate.day + 06);
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
                                      dashboardResult = [];
                                      gettimes();
                                      dataChange();
                                      setState(() {});
                                    },
                                    child: Text("週")),
                              ],
                            ),
                            Visibility(
                                visible: visible,
                                child: Container(
                                  height: 400,
                                  width: 400,
                                  child: SfCircularChart(
                                    title: ChartTitle(
                                        text:
                                            '総時間:${constructTime(selectedTotalTimes)}',
                                        textStyle: TextStyle(fontSize: 13)),
                                    margin: EdgeInsets.only(top: 10),
                                    legend: Legend(
                                        position: LegendPosition.bottom,
                                        isVisible: true,
                                        overflowMode:
                                            LegendItemOverflowMode.wrap),
                                    tooltipBehavior:
                                        TooltipBehavior(enable: true),
                                    onTooltipRender: (
                                      TooltipArgs args,
                                    ) {
                                      String newarg = args.text.toString();
                                      args.text = newarg.substring(
                                          0, newarg.indexOf(":"));
                                    },
                                    series: <CircularSeries>[
                                      PieSeries<Contents, String>(
                                          dataSource: dashboardResult,
                                          xValueMapper: (Contents data, _) =>
                                              data.events,
                                          yValueMapper: (Contents data, _) =>
                                              data.times,
                                          dataLabelMapper: (Contents data, _) =>
                                              "${constructTime(data.times)}",
                                          dataLabelSettings: DataLabelSettings(
                                            isVisible: true,
                                            showCumulativeValues: false,
                                          ),
                                          enableTooltip: true,
                                          legendIconType: LegendIconType.circle)
                                    ],
                                  ),
                                )),
                            Visibility(
                              visible: !visible,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 50),
                                child: Text("この日には何もやっていないよ",
                                    style: TextStyle(fontSize: 16.0)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
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
