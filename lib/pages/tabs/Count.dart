import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:doto_app/model/chartJsonData.dart';
import 'package:doto_app/model/userData.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

enum setdate { date, month, week }

class _CountPage extends State<CountPage> {
  String hasdate = ""; //日付表示
  String hasdate2 = "";
  bool visible = false;
  var selectdate = setdate.date;

  List<Contents> dashboardResult = [];
  List<ChartJsonData> chartJsonData = [];
  List data2 = [];
  int times = 0;
  int totalTimes = 0;
  int selectedTotalTimes = 0;
  Color onSelected = Colors.black87;
  Color onSelected2 = Colors.black87;
  Color onSelected3 = Colors.black87;
  late UserData userdata;

  Future getEvents() async {
    //整理数据
    //print(mySelectedEvents);
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    try {
      Response response = await dio.get("http://www.leishengle.com/api/v1/getgraph");
      if (response.statusCode == 201) {
        //data2 = json.decode(jsonString2);
        //data2 =  json.decode(response.data);
        print(response);
        response.data.forEach((e) {
          print(e);
          //chartJsonData.add(ChartJsonData.fromJson(json.decode(e)));
          chartJsonData.add(ChartJsonData.fromJson(e));
        });
        chartJsonData.forEach((element) {
          element.contents.forEach((e) {
            totalTimes = totalTimes + e.times;
          });
        });
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('グラフ更新しました'),
        duration: Duration(seconds: 1),
      ));
      }
    } catch (onError) {
      debugPrint("error:${onError.toString()}");
    }
  }

  Future userData() async {
    SharedPreferences retult = await SharedPreferences.getInstance();
    retult.getString("userdata") == null
        ? userdata = UserData(name: "", email: "", accessToken: "")
        : userdata =
            UserData.fromJson(json.decode(retult.getString("userdata")));
    if (userdata.accessToken != "") {
      await getEvents();
    }
  }

  @override
  void initState() {
    super.initState();
    String jsonString2 = "";
    hasdate = formatDate(DateTime.now(), [
      'yyyy',
      "-",
      'mm',
      "-",
      'dd',
    ]).toString();
    Future(() async {
     await userData();
      SharedPreferences list = await SharedPreferences.getInstance();
      list.getString("counts") == null
          ? jsonString2 = ""
          : jsonString2 = list.getString("counts");
      gettimes();
      dataChange();
      setState(() {});
    });
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
            dashboardResult.add(Contents(times: e.times, events: e.events));
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
            dashboardResult.add(Contents(times: e.times, events: e.events));
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
          measureFn: (Contents grades, _) => grades.times)
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
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
                  height: ScreenAdapter.height(80),
                  width: ScreenAdapter.width(600),
                  child: Card(
                      child: Container(
                          alignment: Alignment.center,
                          margin:
                              EdgeInsets.only(top: ScreenAdapter.height(10)),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "累計総時間:",
                                  style: TextStyle(
                                      fontSize: ScreenAdapter.size(25),
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: ScreenAdapter.width(20)),
                                Text(
                                  "${constructTime(totalTimes)}",
                                  style: TextStyle(
                                      fontSize: ScreenAdapter.size(25),
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),

                                //   Column(children: [
                                //     Text(
                                //       "平均",
                                //       style: TextStyle(
                                //           fontSize: 18.0,
                                //           // fontStyle: FontStyle.italic,
                                //           color: Colors.green,
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
                                //           color: Colors.green,
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
                    height: ScreenAdapter.height(640),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(ScreenAdapter.width(8)),
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
                                      onSelected = Colors.green;
                                      onSelected2 = Colors.black87;
                                      onSelected3 = Colors.black87;

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
                                      selectedTotalTimes = 0;
                                      gettimes();
                                      dataChange();
                                      setState(() {});
                                    },
                                    child: Text("日")),
                                OutlineButton(
                                    textColor: onSelected3,
                                    onPressed: () {
                                      onSelected3 = Colors.green;
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
                                      selectedTotalTimes = 0;
                                      gettimes();
                                      dataChange();
                                      setState(() {});
                                    },
                                    child: Text("週")),
                                OutlineButton(
                                    textColor: onSelected2,
                                    onPressed: () {
                                      onSelected2 = Colors.green;
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
                                      selectedTotalTimes = 0;
                                      gettimes();
                                      dataChange();
                                      setState(() {});
                                    },
                                    child: Text("月")),
                              ],
                            ),
                            Visibility(
                                visible: visible,
                                child: Container(
                                  height: ScreenAdapter.height(450),
                                  width: ScreenAdapter.width(400),
                                  child: SfCircularChart(
                                    title: ChartTitle(
                                        text:
                                            '総時間:${constructTime(selectedTotalTimes)}',
                                        textStyle: TextStyle(
                                            fontSize: ScreenAdapter.size(23))),
                                    margin: EdgeInsets.only(
                                        top: ScreenAdapter.height(10)),
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
                                margin: EdgeInsets.only(
                                    top: ScreenAdapter.height(50)),
                                child: Text("この日には何もやっていないよ",
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.size(23))),
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
