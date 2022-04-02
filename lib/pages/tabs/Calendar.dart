import 'dart:async';
import 'dart:collection';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:doto_app/main.dart';
import 'package:doto_app/model/alarm.dart';
import 'package:doto_app/model/eventsToJoson.dart';
import 'package:doto_app/model/myevents.dart';
import 'package:doto_app/model/userData.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:doto_app/widget/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:doto_app/pages/tabs/Calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final todaysDate = DateTime.now();
  var _focusedCalendarDate = DateTime.now();
  final _initialCalendarDate = DateTime(2000);
  final _lastCalendarDate = DateTime(3000);
  DateTime? selectedCalendarDate;
  final titleController = TextEditingController();
  final descpController = TextEditingController();
  final dateController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<MyEvents>> mySelectedEvents;
  // List<MyAlarm> myAlarm = [];
  int alarmId = 1;
  late UserData userdata;
  bool visible = false; //アラーム表示するか
  late Map setChartJsonData;
  List setdate = [];
  late Map<DateTime, List<MyEvents>> _events; //ローカルに保存用
  late SharedPreferences prefs;
  List<MyEvents> list = [];
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  List storge = [];
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    selectedCalendarDate = _focusedCalendarDate;
    mySelectedEvents = {};
    _events = {};
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
    Future(() async {
      prefs = await SharedPreferences.getInstance();
      // setState(() {
      //   mySelectedEvents =
      //       decodeMap(json.decode(prefs.getString("events") ?? "{}"));
      // });

      // prefs.getString("myAlarm") == null
      //     ? storge = []
      //     : storge = json.decode(prefs.getString("myAlarm") ?? "{}");
      // storge.forEach((e) {
      //   myAlarm.add(MyAlarm.fromJson(json.decode(e)));
      // });
      // if (myAlarm.isNotEmpty) {
      // alarmId = myAlarm.last.alarmId + 1;
      //}
      //prefs.remove("myAlarm");
      //prefs.remove("events");

      //print(prefs.getString("events").toString());
      userData();
    });
  }

  Future userData() async {
    SharedPreferences retult = await SharedPreferences.getInstance();
    retult.getString("userdata") == null
        ? userdata = UserData(name: "", email: "", accessToken: "")
        : userdata =
            UserData.fromJson(json.decode(retult.getString("userdata")));
    if (userdata.accessToken != "") {
      //先拿到数据，比较更新时间，如果时间比本地靠后，就执行更新，否则不执行本地更新
      //本地数据拿出来发给后台对比
      //然后再查询，返回查询数据，显示出来
      getEvents();
    }
  }

  Future deleteMyEvents(MyEvents events, DateTime selectedCalendarDate) async {
    var date = DateFormat('yyyy-MM-dd').format(selectedCalendarDate);
    Map calendar = {};
    List calendarlist = [];
    List eventslist = [];
    eventslist.add(events.toJson());

    calendar["calendar"] = date.toString();
    calendar["events"] = eventslist;
    calendarlist.add(calendar);
    print(calendarlist);
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    try {
      Response response = await dio.post(
          "http://www.leishengle.com/api/v1/deletemyevents",
          data: jsonEncode(calendarlist));
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メモ削除成功'),
          duration: Duration(seconds: 1),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text('メモ削除失敗'),
          duration: Duration(seconds: 1),
        ));
      }
    } on DioError catch (e) {
      //400是错误，后台写法需要修改
      if(e.response.statusCode==400){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メモ削除成功'),
          duration: Duration(seconds: 1),
        ));
      }
    }
  }

  Future sendEvents(Map<DateTime, List<MyEvents>> myEvents) async {
    //更新数据
    //整理数据
    List calendarlist = [];
    myEvents.forEach((key, value) {
      Map calendar = {};
      calendar["calendar"] = key.toString();
      calendar["events"] = value.map((v) => v.toJson()).toList();
      calendarlist.add(calendar);
    });
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    Response response = await dio.post(
        "http://www.leishengle.com/api/v1/myevents",
        data: jsonEncode(calendarlist));
    if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('メモ追加成功'),
          duration: Duration(seconds: 1),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text('メモ追加失敗'),
          duration: Duration(seconds: 1),
        ));
      }
  }

  Future getEvents() async {
    //整理数据
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    try {
      Response response =
          await dio.get("http://www.leishengle.com/api/v1/sendmyevents");
      List<MyEvents> list = [];
      DateTime date;
      Map<DateTime, List<MyEvents>> newMap = {};
      if (response.statusCode == 201) {
        response.data.forEach((element) {
          newMap[DateTime.parse(element["calendar"])] = element["events"]
              .map((f) => MyEvents.fromJson(f))
              .toList()
              .cast<MyEvents>();
        });
        setState(() {
          mySelectedEvents = newMap;
        });
      }
    } catch (onError) {
      debugPrint("error:${onError.toString()}");
    }
  }

  Map<String, dynamic> encodeMap(Map<DateTime, List<MyEvents>> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, List<MyEvents>> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, List<MyEvents>> newMap = {};
    List<MyEvents> list = [];
    map.forEach((key, value) {
      value.forEach((e) {
        list.add(MyEvents.fromJson(e));
        if (alarmId < MyEvents.fromJson(e).alarmId) {
          alarmId = MyEvents.fromJson(e).alarmId + 1;
        }
      });
      if (list != []) {
        newMap[DateTime.parse(key)] = list;
        list = [];
      }
    });
    return newMap;
  }

  //時間の選択
  _showDatePicker() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'キャンセル',
                      style: TextStyle(
                          fontSize: ScreenAdapter.size(16),
                          color: Colors.green),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '確認',
                      style: TextStyle(
                          fontSize: ScreenAdapter.size(16),
                          color: Colors.green),
                    )),
              ],
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoDatePicker(
                use24hFormat: true,
                initialDateTime: selectedCalendarDate,
                mode: CupertinoDatePickerMode.dateAndTime, //这里改模式
                onDateTimeChanged: (dateTime) {
                  dateController.text =
                      "${dateTime.year}-${_convertTwoDigits(dateTime.month)}-${_convertTwoDigits(dateTime.day)} ${_convertTwoDigits(dateTime.hour)}:${_convertTwoDigits(dateTime.minute)}"
                          .toString();
                },
              ),
            ),
          ]);
        }).whenComplete(() async {});
  }

  String _convertTwoDigits(int number) {
    return number >= 10 ? "$number" : "0$number";
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
    _connectionStatus = result;
    if (_connectionStatus == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text('ネットワークに繋がっていません'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descpController.dispose();
    dateController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  List<MyEvents> _listOfDayEvents(DateTime dateTime) {
    final _events = LinkedHashMap<DateTime, List<MyEvents>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(mySelectedEvents);

    return _events[dateTime] ?? [];
  }

  Widget buildTextField(
      {String? hint, required TextEditingController controller}) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: Colors.green,
            ),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: hint ?? '',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
        ),
      ),
    );
  }

  checkLocked() {
    return showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                //在这里为了区分，在构建builder的时候将setState方法命名为了setBottomSheetState。
                builder: (context1, showDialogState) {
              return AlertDialog(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ログインへ'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'キャンセル',
                      style: TextStyle(
                          fontSize: ScreenAdapter.size(15),
                          color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
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

  _showAddEventDialog() async {
    await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
                //在这里为了区分，在构建builder的时候将setState方法命名为了setBottomSheetState。
                builder: (context1, showDialogState) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('メモ'),
                    TextButton(
                      onPressed: () async {
                        showDialogState(() {
                          visible = true;
                        });
                        await _showDatePicker();
                      },
                      child: Text('アラーム設定',
                          style: TextStyle(
                              fontSize: ScreenAdapter.size(15),
                              color: Colors.green)),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildTextField(controller: titleController, hint: 'タイトル'),
                      SizedBox(
                        height: ScreenAdapter.height(23),
                      ),
                      buildTextField(controller: descpController, hint: 'メモ'),
                      SizedBox(
                        height: ScreenAdapter.height(23),
                      ),
                      visible
                          ? buildTextField(
                              controller: dateController, hint: 'アラーム')
                          : Container(),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル',
                        style: TextStyle(color: Colors.green)),
                  ),
                  TextButton(
                    onPressed: () async {
                      var date = DateFormat('yyyy-MM-dd')
                          .format(selectedCalendarDate!);
                      int localAlarmId = alarmId;
                      //现在最大ID取得
                      if (titleController.text.isEmpty ||
                          descpController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.deepOrange,
                            content: Text('全ての内容を入力してください'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        //return;
                      } else {
                        setState(() {
                          if (mySelectedEvents[DateTime.parse(date)] != null) {
                            mySelectedEvents[DateTime.parse(date)]?.add(
                                MyEvents(
                                    eventTitle: titleController.text,
                                    eventDescp: descpController.text,
                                    alarm: dateController.text,
                                    alarmId: alarmId,
                                    status: 0,
                                    updatetime: DateTime.now().toString()));
                          } else {
                            mySelectedEvents[DateTime.parse(date)] = [
                              MyEvents(
                                  eventTitle: titleController.text,
                                  eventDescp: descpController.text,
                                  alarm: dateController.text,
                                  alarmId: alarmId,
                                  status: 0,
                                  updatetime: DateTime.now().toString())
                            ];
                          }
                        });

                        //アラームの設定があるか
                        if (dateController.text != "") {
                          // myAlarm.add(MyAlarm(
                          //     alarmId: alarmId,
                          //     alarmTitle: titleController.text,
                          //     alarmSubTitle: descpController.text,
                          //     alarmDate: dateController.text,
                          //     status: 0));
                          scheduleAlarm(DateTime.parse(dateController.text),
                              titleController.text, alarmId);
                        }
                        alarmId++;
                        mySelectedEvents.forEach((key, value) {
                          var date = DateFormat('yyyy-MM-dd').format(key);
                          _events[DateTime.parse(date)] = value;
                        });
                        //发送api
                        await sendEvents(mySelectedEvents);
                        // prefs.setString(
                        //     "events", json.encode(encodeMap(_events)));

                        //アラーム保存
                        // List<String> events = myAlarm
                        //     .map((f) => json.encode(f.toJson()))
                        //     .toList();
                        //prefs.setString("myAlarm", json.encode(events));
                        //入力した内容をクリアする
                        titleController.clear();
                        descpController.clear();
                        dateController.clear();
                        visible = false;
                        Navigator.pop(context);
                        //return;
                      }
                    },
                    child:
                        const Text('確認', style: TextStyle(color: Colors.green)),
                  ),
                ],
              );
            }));
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
                centerTitle: true,
                title: Text("カレンダー"),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_connectionStatus == ConnectivityResult.none) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Colors.deepOrange,
                            content: Text('ネットワークに繋がっていません'),
                            duration: Duration(seconds: 1),
                          ));
                        } else {
                          if (userdata.name != "") {
                            _showAddEventDialog();
                          } else {
                            checkLocked();
                          }
                        }
                      }),
                ]),
            body: SingleChildScrollView(
                child: Column(children: [
              Card(
                margin: EdgeInsets.all(
                  ScreenAdapter.height(20),
                ),
                elevation: 15.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  //カレンダー外側の枠
                  side: BorderSide(
                      color: Colors.white, width: ScreenAdapter.width(2)),
                ),
                child: TableCalendar(
                  locale: 'ja_JP',
                  //今日の時間
                  focusedDay: _focusedCalendarDate,
                  // 2000年から
                  firstDay: _initialCalendarDate,
                  // 3000年まで
                  lastDay: _lastCalendarDate,
                  calendarFormat: _calendarFormat,
                  weekendDays: [DateTime.sunday, 6],
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  daysOfWeekHeight: ScreenAdapter.height(40),
                  rowHeight: ScreenAdapter.height(60),
                  //eventLoader: _listOfDayEvents,
                  eventLoader: _listOfDayEvents,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return _buildEventsMarker(date, events);
                      }
                    },
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                        color: Colors.black, fontSize: ScreenAdapter.size(20)),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    // formatButtonTextStyle:
                    //     TextStyle(color: Colors.green, fontSize: 16.0),
                    // formatButtonDecoration: BoxDecoration(
                    //   color: Colors.black,
                    //   borderRadius: BorderRadius.all(
                    //     Radius.circular(5.0),
                    //   ),
                    // ),
                    //矢印
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                      size: ScreenAdapter.size(28),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                      size: ScreenAdapter.size(28),
                    ),
                  ),
                  // Calendar Days Styling
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    // Weekend days color (Sat,Sun)
                    weekendStyle: TextStyle(color: Colors.green),
                  ),
                  // Calendar Dates styling
                  calendarStyle: const CalendarStyle(
                    // Weekend dates color (Sat & Sun Column)
                    weekendTextStyle: TextStyle(color: Colors.green),
                    // highlighted color for today
                    todayDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    // highlighted color for selected day
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                        color: Colors.green, shape: BoxShape.circle),
                  ),
                  selectedDayPredicate: (currentSelectedDate) {
                    // as per the documentation 'selectedDayPredicate' needs to determine
                    // current selected day
                    return (isSameDay(
                        selectedCalendarDate!, currentSelectedDate));
                  },
                  onPageChanged: (focusedDay) {
                    _focusedCalendarDate = focusedDay;
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    // as per the documentation
                    if (!isSameDay(selectedCalendarDate, selectedDay)) {
                      setState(() {
                        selectedCalendarDate = selectedDay;
                        _focusedCalendarDate = focusedDay;
                      });
                    }
                  },
                ),
              ),
              ..._listOfDayEvents(selectedCalendarDate!)
                  .map((myEvents) => Padding(
                      padding: EdgeInsets.all(ScreenAdapter.height(5)),
                      child: ListTile(
                        onTap: () {},
                        title: Padding(
                          padding:
                              EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                          child: Text('タイトル:　${myEvents.eventTitle}'),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('メモ:　${myEvents.eventDescp}'),
                            myEvents.alarm == ""
                                ? Text('')
                                : Text('アラーム時間:　${myEvents.alarm}'),
                          ],
                        ),
                        trailing: IconButton(
                            onPressed: () async {
                              var index =
                                  _listOfDayEvents(selectedCalendarDate!)
                                      .indexOf(myEvents);
                              //var alramIndex = 0;
                              var alramId = 0;
                              if (_listOfDayEvents(selectedCalendarDate!)[index]
                                      .alarm !=
                                  "") {
                                alramId = _listOfDayEvents(
                                        selectedCalendarDate!)[index]
                                    .alarmId;
                              }
                              //アラームの削除
                              await flutterLocalNotificationsPlugin
                                  .cancel(alramId);
                              await deleteMyEvents(
                                  _listOfDayEvents(
                                      selectedCalendarDate!)[index],
                                  selectedCalendarDate!);
                              //更改对应状态
                              setState(() {
                                _listOfDayEvents(selectedCalendarDate!)
                                    .removeAt(index);
                              });

                              if (_listOfDayEvents(selectedCalendarDate!)
                                  .isEmpty) {
                                //选中的日期里没有内容就删除日期
                                var date = DateFormat('yyyy-MM-dd')
                                    .format(selectedCalendarDate!);
                                mySelectedEvents.remove(DateTime.parse(date));
                              }
                            },
                            icon: Icon(Icons.delete)),
                      )))
            ]))));
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: ScreenAdapter.width(10),
      bottom: ScreenAdapter.height(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red[300],
        ),
        width: ScreenAdapter.width(16),
        height: ScreenAdapter.height(16),
        child: Center(
          child: Text(
            '${events.length}',
            style: TextStyle().copyWith(
              color: Colors.white,
              fontSize: ScreenAdapter.size(12),
            ),
          ),
        ),
      ),
    );
  }
}

//https://www.youtube.com/watch?v=bRy5dmts3X8
//参考サイド
void scheduleAlarm(
    DateTime scheduledNotificationDateTime, String alarmInfo, int id) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    channelDescription: 'Channel for Alarm notification',
    icon: 'ic_launcher',
    sound: RawResourceAndroidNotificationSound('clock'),
    playSound: true,
    largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
  );

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'clock.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(
    id,
    'リマインド!',
    alarmInfo + "の時間だよ!",
    scheduledNotificationDateTime,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
  );
}
