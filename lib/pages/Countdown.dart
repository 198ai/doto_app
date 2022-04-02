import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';

import 'dart:developer' as developer;
import 'package:doto_app/model/chartJsonData.dart';
import 'package:doto_app/model/ringtonePlayer.dart';
import 'package:doto_app/model/tasklist.dart';
import 'package:doto_app/model/userData.dart';
import 'package:doto_app/pages/tabs/Tabs.dart';
import 'package:doto_app/pages/tabs/ToDoList.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountDown extends StatefulWidget {
  int time;
  int date;
  String title;
  int index;
  int id;
  CountDown({
    Key? key,
    this.date = 0,
    this.time = 0,
    this.title = "",
    this.index = 0,
    this.id = 0,
  }) : super(key: key);
  @override
  _CountdownState createState() =>
      _CountdownState(this.date, this.time, this.title, this.id);
}

class _CountdownState extends State<CountDown> {
  int time;
  int date;
  String title;
  int id;
  Alarm alarm = new Alarm();
  _CountdownState(this.date, this.time, this.title, this.id) : super();
  var _timer;
  int seconds = 0;
  bool running = false;
  //List<TodoModel> todos = [];
  //List storge = []; //ローカルから取り出した値をここに
  //List<ChartJsonData> getCountDate = [];
  //List countDate = [];
  late ChartJsonData data;
  List<Contents> contents = [];
  List<String> eventsNames = [];
  late UserData userdata;
  late var formatToday;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    startTimer();
    //data = ChartJsonData(date: "", contents: contents);
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
      //获取user token
      list.getString("userdata") == null
          ? userdata = UserData(name: "", email: "", accessToken: "")
          : userdata =
              UserData.fromJson(json.decode(list.getString("userdata")));

      if (list.getString("userdata") != null) {
        userdata = UserData.fromJson(json.decode(list.getString("userdata")));
      } else {
        userdata = UserData(name: "", email: "", accessToken: "");
      }

      // list.getString("toDoList") == null
      //     ? storge = []
      //     : storge = json.decode(list.getString("toDoList") ?? "{}");
      // storge.forEach((e) {
      //   todos.add(TodoModel.fromJson(json.decode(e)));
      // });
      // list.getString("counts") == null
      //     ? countDate = []
      //     : countDate = json.decode(list.getString("counts"));
      // countDate.forEach((e) {
      //   getCountDate.add(ChartJsonData.fromJson(json.decode(e)));
      // });
      // getCountDate.forEach((element) {
      //   if (element.date == formatToday) {
      //     element.contents.forEach((e) {
      //       eventsNames.add(e.events);
      //     });
      //   }
      // });
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
          int differTimes = time - seconds;
          time = seconds;
          //saveTime(time);
          if (differTimes != 0) {
            updatetodolist(differTimes);
          }
          _showADialog();
        }
      });
    }
  }

  void stopTimer() async {
    if (running && seconds != 0) {
      int differTimes = time - seconds;
      time = seconds;
      cancelTimer();
      //saveTime(time);
      if (differTimes != 0) {
        updatetodolist(differTimes);
      }
      _timer = null;
    } else {
      startTimer();
    }
  }

  updatetodolist(int differTimes) async {
    ///本地存储的数据先更新给API，同步数据
    ///然后更新本地数据
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var params = {
      "id": id,
      "complete": 0,
      "time": time,
      "differTimes": differTimes,
      "date": formatToday
    };

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    print('時間更新:${params}');
    Response response = await dio
        .post("http://www.leishengle.com/api/v1/updatetime", data: params);
    print(response.data);
    if (response.statusCode != null && response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('時間更新しました'),
        duration: Duration(seconds: 1),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('時間の更新に失敗しました'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  //変更された時間を再保存
  void saveTime(int time) async {
    //int differTimes = int.parse(todos[widget.index].time) - time;
    int differTimes = widget.time - time;
    //todos[widget.index].time = time.toString();
    // SharedPreferences list = await SharedPreferences.getInstance();
    // List<String> events = todos.map((f) => json.encode(f.toJson())).toList();
    // list.setString("toDoList", json.encode(events));
    //

    //makeCountData(differTimes);
    //postgraph(differTimes);
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
    _connectivitySubscription.cancel();
    cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () => {
                  stopTimer(),
                  cancelTimer(),
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Tabs(tabSelected: 0)))
                },
              ),
              centerTitle: true,
              title: Text('タイマー'),
            ),
            body: Stack(children: [
              Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(
                        top: ScreenAdapter.height(150),
                        right: ScreenAdapter.width(10),
                        left: ScreenAdapter.width(10),
                      ),
                      alignment: Alignment.topCenter,
                      child: Text(constructTime(seconds),
                          style: TextStyle(
                              fontSize: ScreenAdapter.size(90),
                              color: Colors.black87))),
                  Container(
                    margin: EdgeInsets.only(top: ScreenAdapter.height(180)),
                    alignment: Alignment.topCenter,
                    child: TextButton(
                        child: Text("停止",
                            style: TextStyle(
                                fontSize: ScreenAdapter.size(70),
                                color: Colors.black87)),
                        onPressed: () async {
                          if (_connectionStatus == ConnectivityResult.none) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor: Colors.deepOrange,
                              content: Text('ネットワークに繋がっていません'),
                              duration: Duration(seconds: 1),
                            ));
                            return;
                          } else {
                            stopTimer();
                          }
                        }),
                  )
                ],
              )
            ])));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
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
                    Text(
                      'お疲れ様でした！',
                      style: TextStyle(
                          fontSize: ScreenAdapter.size(15),
                          color: Colors.green),
                    ),
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
                    child: Text(
                      '確認',
                      style: TextStyle(
                          fontSize: ScreenAdapter.size(15),
                          color: Colors.green),
                    ),
                  ),
                ],
              );
            }));
  }
}
