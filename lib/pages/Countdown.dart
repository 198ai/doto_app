import 'dart:async';
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:doto_app/model/chartJsonData.dart';
import 'package:doto_app/model/ringtonePlayer.dart';
import 'package:doto_app/model/tasklist.dart';
import 'package:doto_app/pages/tabs/Tabs.dart';
import 'package:doto_app/pages/tabs/ToDoList.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountDown extends StatefulWidget {
  int time;
  int date;
  String name;
  int index;
  CountDown({
    Key? key,
    this.date = 0,
    this.time = 0,
    this.name = "",
    this.index = 0,
  }) : super(key: key);
  @override
  _CountdownState createState() =>
      _CountdownState(this.date, this.time, this.name);
}

class _CountdownState extends State<CountDown> {
  int time;
  int date;
  String name;
  Alarm alarm = new Alarm();
  _CountdownState(this.date, this.time, this.name) : super();
  var _timer;
  int seconds = 0;
  bool running = false;
  List<TodoModel> todos = [];
  List storge = []; //ローカルから取り出した値をここに
  List<ChartJsonData> getCountDate = [];
  List countDate = [];
  late ChartJsonData data;
  List<Contents> contents = [];
  List<String> eventsNames = [];
  late var formatToday;
  //时间格式化，根据总秒数转换为对应的 hh:mm:ss 格式
  String constructTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(hour) +
        ":" +
        formatTime(minute) +
        ":" +
        formatTime(second);
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    data = ChartJsonData(date: "", contents: contents);
    //日付取得
    var today = DateTime.now();
    formatToday = formatDate(today, [
      'yyyy',
      "-",
      'mm',
      "-",
      'dd',
    ]).toString();
    Future(() async {
      SharedPreferences list = await SharedPreferences.getInstance();
      list.getString("toDoList") == null
          ? storge = []
          : storge = json.decode(list.getString("toDoList") ?? "{}");
      storge.forEach((e) {
        todos.add(TodoModel.fromJson(json.decode(e)));
      });
      list.getString("counts") == null
          ? countDate = []
          : countDate = json.decode(list.getString("counts"));
      countDate.forEach((e) {
        getCountDate.add(ChartJsonData.fromJson(json.decode(e)));
      });
      getCountDate.forEach((element) {
        if (element.date == formatToday) {
          element.contents.forEach((e) {
            eventsNames.add(e.events);
          });
        }
      });
    });
  }

  void startTimer() {
    //获取当期时间
    running = true;
    var now = DateTime.now();
    if (time != 0) {
      var twoHours = now.add(Duration(seconds: time)).difference(now);
      seconds = twoHours.inSeconds;

      //设置 1 秒回调一次
      const period = const Duration(seconds: 1);
      _timer = Timer.periodic(period, (timer) {
        //更新界面
        setState(() {
          //秒数减一，因为一秒回调一次
          seconds--;
        });

        if (seconds == 0) {
          //倒计时秒数为0，取消定时器
          cancelTimer();
          time = seconds;
          saveTime(time);
          _showADialog();
        }
      });
    }
  }

  void stopTimer() async {
    if (running && seconds != 0) {
      time = seconds;
      cancelTimer();
      saveTime(time);
      _timer = null;
    } else {
      startTimer();
    }
  }

  //変更された時間を再保存
  void saveTime(int time) async {
    int differTimes = int.parse(todos[widget.index].time) - time;
    todos[widget.index].time = time.toString();
    SharedPreferences list = await SharedPreferences.getInstance();
    List<String> events = todos.map((f) => json.encode(f.toJson())).toList();
    list.setString("toDoList", json.encode(events));
    makeCountData(differTimes);
  }

  void cancelTimer() {
    running = false;
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  //統計画面のデータ設定
  makeCountData(int differTimes) async {
    SharedPreferences list = await SharedPreferences.getInstance();
    Contents localcontents = Contents(events: "", times: 0);
    bool newdata = false;
    //記録時間取得
    //イベント名前取得
    if (getCountDate.isNotEmpty && eventsNames.isNotEmpty) {
      getCountDate.forEach((element) {
        //今日の記録タスクがある場合
        if (element.date == formatToday) {
          for (var e in element.contents) {
            //今日重複やったタスク
            if (eventsNames.contains(todos[widget.index].title)) {
              if (e.events == todos[widget.index].title) {
                var newTimes = differTimes + e.times;
                e.times = newTimes;
              }
            } else if (!eventsNames.contains(todos[widget.index].title)) {
              //今日はじめてやったタスク
              eventsNames.add(todos[widget.index].title);
              newdata = true;
              localcontents = Contents(
                  events: todos[widget.index].title, times: differTimes);
            }
          }
          if (newdata) {
            element.contents.add(localcontents);
            newdata = false;
          }
        }
      });
    } else {
      eventsNames.add(todos[widget.index].title);
      contents
          .add(Contents(events: todos[widget.index].title, times: differTimes));
      data = ChartJsonData(date: formatToday, contents: contents);
      getCountDate.add(data);
      List<String> countData =
          getCountDate.map((f) => json.encode(f.toJson())).toList();
      list.setString("counts", json.encode(countData));
    }
    List<String> countData =
        getCountDate.map((f) => json.encode(f.toJson())).toList();
    list.setString("counts", json.encode(countData));
    //list.remove("counts");
    print(countData);
  }

  @override
  void dispose() {
    super.dispose();
    cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            onPressed: () => {
              stopTimer(),
              cancelTimer(),
              alarm.stop(),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Tabs(tabSelected: 0)))
            },
          ),
          centerTitle: true,
          title: Text('タイマー'),
        ),
        body: Stack(children: [
          Column(
            children: [
              Container(
                  margin: EdgeInsets.only(top: 150),
                  alignment: Alignment.topCenter,
                  child: Text(constructTime(seconds),
                      style: TextStyle(fontSize: 80, color: Colors.black87))),
              Container(
                margin: EdgeInsets.only(top: 150),
                alignment: Alignment.topCenter,
                child: TextButton(
                    child: Text("停止",
                        style: TextStyle(fontSize: 50, color: Colors.black87)),
                    onPressed: () {
                      stopTimer();
                    }),
              )
            ],
          )
        ]));
  }

  _showADialog() {
    alarm.start();
    Future.delayed(Duration(milliseconds: 6000), () {
      alarm.stop();
    });
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                //在这里为了区分，在构建builder的时候将setState方法命名为了setBottomSheetState。
                builder: (context1, showDialogState) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('お疲れ様でした！'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      alarm.stop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Tabs(tabSelected: 0)));
                    },
                    child: const Text('確認'),
                  ),
                ],
              );
            }));
  }
}
