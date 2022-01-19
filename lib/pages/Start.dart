import 'dart:async';

import 'package:doto_app/pages/tabs/ToDoList.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  int time;
  int date;
  StartPage({
    Key? key,
    this.date = 0,
    this.time = 0,
  }) : super(key: key);

  _StartPageState createState() => _StartPageState(this.date, this.time);
}

class _StartPageState extends State<StartPage> {
  GlobalKey<_StartPageState> globalKey = GlobalKey();
  int time;
  int date;
  _StartPageState(this.date, this.time) : super();

  /// 初期値
  var _timeString = '00:00:00';
  var _countdownTime;
  var hour;
  var minutes;
  var second;
  var mod;

  /// 開始時間
  late DateTime _startTime;

  /// ローカルタイマー
  var _timer;
  var _isStart = false;
  //差値
  List laps = [];
  List _deltaList = []; //储存差值 类型int 单位mill second
  int _maxIndex = 0; // 最大值的索引
  int _minIndex = 0; // 最小值的索引

  @override
  void initState() {
    super.initState();
    //先判断初期值是否存在
    /**
     * 有初期值就倒计时，没有就正向记时
     * 每次暂停，记录经过值
     * 返回到主页的时候已经有的值减去经过的值，更新页面
     */
    _timeString = _formatDateTime(this.time);
    print(_timeString);
    //获取当期时间
    var now = DateTime.now();
    //获取 2 分钟的时间间隔
    var twoHours = now.add(Duration(seconds: time)).difference(now);
    //获取总秒数，2 分钟为 120 秒
    time = twoHours.inSeconds;
    startTimer();
  }
  void startTimer() {
    //设置 1 秒回调一次
    const period = const Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      //更新界面
      setState(() {
        //秒数减一，因为一秒回调一次
        time--;
      });
      if (time == 0) {
        //倒计时秒数为0，取消定时器
        cancelTimer();
      }
    });
  }

   void cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
  //时间格式化，根据总秒数转换为对应的 hh:mm:ss 格式
  String constructTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(hour) + ":" + formatTime(minute) + ":" + formatTime(second);
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  // 计次操作
  void lap() {
    if (!_isStart) {
      restartTime();
      return;
    }
    // 获取调用瞬间的时间
    var now = DateTime.now();
    var times = hour * 3600 + minutes * 60 + second;

    laps.add(times);
    if (laps.length > 1) {
      _deltaList.add(laps[laps.length - 1] - laps[laps.length - 2]);
    }
    // 遍历时间差值list, 获取最大最小的值的索引
    if (_deltaList.length > 1) {
      _minIndex = 0;
      _maxIndex = 0;
      for (int i = 0; i < _deltaList.length; i++) {
        if (_deltaList[_maxIndex] < _deltaList[i]) {
          _maxIndex = i;
        }
        if (_deltaList[_minIndex] > _deltaList[i]) {
          _minIndex = i;
        }
      }
    }
  }

  void _startTimer() {
   
      setState(() {
        _isStart = !_isStart;
        if (_isStart) {
          _startTime = DateTime.now();
          _timer = Timer.periodic(Duration(seconds: 1), _onTimer);
        } else {
          _timer.cancel();
        }
      });
    
  }

  void _onTimer(Timer timer) {
    /// 現在時刻を取得
    var now = DateTime.now();

    /// 開始時刻と比較して差分を取得
    var diff = now.difference(_startTime).inSeconds;

    /// タイマーのロジック
    hour = (diff / (60 * 60)).floor();
    mod = diff % (60 * 60);
    minutes = (mod / 60).floor();
    second = mod % 60;

    setState(() => {
          _timeString =
              """${_convertTwoDigits(hour)}:${_convertTwoDigits(minutes)}:${_convertTwoDigits(second)}"""
        });
  }

  String _convertTwoDigits(int number) {
    return number >= 10 ? "$number" : "0$number";
  }

  // リセット
  void restartTime() {
    laps.clear();
    _deltaList.clear();
    setState(() {
      _timeString = '00:00:00';
      _isStart = false;
      _maxIndex = 0;
      _minIndex = 0;
    });
  }

  var differTime;
  // 格式化输出DateTime, 主要进行的是补0操作
  String _formatDateTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    differTime =
        """${_convertTwoDigits(hour)}:${_convertTwoDigits(minute)}:${_convertTwoDigits(second)}""";
    return differTime;
  }

  @override
  void dispose() {
    super.dispose();
    cancelTimer();
    if (_timer != null) {
      // 页面销毁时触发定时器销毁
      if (_timer.isActive) {
        // 判断定时器是否是激活状态
        _timer.cancel();
      }
    }
    laps.clear();
    _deltaList.clear();
    _timeString = '00:00:00';
    _isStart = false;
    _maxIndex = 0;
    _minIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8ddf67),
        centerTitle: true,
        title: Text('スタート'),
      ),
      
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.only(top: 50),
                      alignment: Alignment.topCenter,
                      child: time ==0 ?
                      Text(_timeString,
                          style: TextStyle(
                            fontSize: 50,
                            color: Colors.black87,
                          )):Text(constructTime(time),
                            style: TextStyle(
                            fontSize: 50,
                            color: Colors.black87,
                          )))
                          ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: FloatingActionButton(
                          heroTag: "btn1",
                          onPressed: _startTimer,
                          child:
                              Icon(_isStart ? Icons.pause : Icons.play_arrow),
                          tooltip: _isStart ? "暂停" : "开始",
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: FloatingActionButton(
                          heroTag: "btn2",
                          onPressed: () {
                            lap();
                          },
                          child: Icon(!_isStart
                              ? Icons.settings_backup_restore
                              : Icons.alarm_add),
                          tooltip: _isStart ? "计次" : "重置",
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Expanded(
                  flex: 4,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      Color color = Colors.grey;
                      if (index == laps.length - 1) {
                        color = Colors.black;
                      }
                      return Card(
                        margin:
                            EdgeInsets.only(right: 15, left: 15, bottom: 15),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white), //背景颜色
                          ),
                          onPressed: () {},
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 4),
                            dense: true,
                            leading: Padding(
                                padding: EdgeInsets.only(left: 22),
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(fontSize: 18.0),
                                  textAlign: TextAlign.center,
                                )),
                            title: Align(
                              widthFactor: 4,
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  _formatDateTime(laps[index]),
                                  style:
                                      TextStyle(fontSize: 27.0, color: color),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: laps.length,
                  ))
            ],
          )
        ],
      ),
    );
  }
}
