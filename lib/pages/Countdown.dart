import 'dart:async';
import 'dart:convert';

import 'package:doto_app/model/tasklist.dart';
import 'package:doto_app/pages/tabs/Tabs.dart';
import 'package:doto_app/pages/tabs/ToDoList.dart';
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
  _CountdownState(this.date, this.time, this.name) : super();
  var _timer;
  int seconds = 0;
  bool running = false;
  List<TodoModel> todos = [];
  List storge = []; //ローカルから取り出した値をここに
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
    Future(() async {
      SharedPreferences list = await SharedPreferences.getInstance();
      list.getString("toDoList") == null
          ? storge = []
          : storge = json.decode(list.getString("toDoList") ?? "{}");
      print(storge);
      storge.forEach((e) {
        todos.add(TodoModel.fromJson(json.decode(e)));
      });
    });
  }

  void startTimer() {
    //获取当期时间
    running = true;
    var now = DateTime.now();
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
      }
    });
  }

  void stopTimer() async {
    SharedPreferences list = await SharedPreferences.getInstance();
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
    todos[widget.index].time =time.toString();
    SharedPreferences list = await SharedPreferences.getInstance();
    List<String> events = todos.map((f) => json.encode(f.toJson())).toList();
    list.setString("toDoList", json.encode(events));
  }

  void cancelTimer() {
    running = false;
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
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
}
