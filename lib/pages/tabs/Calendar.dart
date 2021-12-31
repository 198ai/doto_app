import 'dart:collection';

import 'package:date_format/date_format.dart';
import 'package:doto_app/main.dart';
import 'package:doto_app/model/alarm.dart';
import 'package:doto_app/model/myevents.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
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
  List<MyAlarm> myAlarm = [];
  int alarmId = 1;
  bool visible = false; //アラーム表示するか
  late Map setChartJsonData;
  List setdate = [];
  late Map<DateTime, List<MyEvents>> _events; //ローカルに保存用
  late SharedPreferences prefs;
  List<MyEvents> list = [];
  List storge = [];
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    selectedCalendarDate = _focusedCalendarDate;
    mySelectedEvents = {};
    _events = {};
    super.initState();
    Future(() async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        mySelectedEvents =
            decodeMap(json.decode(prefs.getString("events") ?? "{}"));
      });

      prefs.getString("myAlarm") == null
          ? storge = []
          : storge = json.decode(prefs.getString("myAlarm") ?? "{}");
      storge.forEach((e) {
        myAlarm.add(MyAlarm.fromJson(json.decode(e)));
      });
      if (myAlarm.isNotEmpty) {
        alarmId = myAlarm.last.alarmId + 1;
      }
      print("初始化$alarmId");
      // prefs.remove("myAlarm");
      // prefs.remove("events");
      //print(storge);
    });
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
                      style: TextStyle(fontSize: 13),
                    )),
                // ignore: deprecated_member_use
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '確認',
                      style: TextStyle(fontSize: ScreenAdapter.size(13)),
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

  @override
  void dispose() {
    titleController.dispose();
    descpController.dispose();
    dateController.dispose();
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
    return TextField(
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
    );
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
                    Text('リマインド'),
                    TextButton(
                      onPressed: () async {
                        showDialogState(() {
                          visible = true;
                        });
                        await _showDatePicker();
                      },
                      child: Text('アラーム設定'),
                    ),
                  ],
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextField(controller: titleController, hint: 'タイトル'),
                    const SizedBox(
                      height: 20.0,
                    ),
                    buildTextField(controller: descpController, hint: 'メモ'),
                    const SizedBox(
                      height: 20.0,
                    ),
                    visible
                        ? buildTextField(
                            controller: dateController, hint: 'アラーム')
                        : Container(),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var date = DateFormat('yyyy-MM-dd')
                          .format(selectedCalendarDate!);
                      int localAlarmId = alarmId;
                      if (titleController.text.isEmpty &&
                          descpController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('全ての内容を入力してください'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        //Navigator.pop(context);
                        return;
                      } else {
                        setState(() {
                          localAlarmId =
                              dateController.text == "" ? 0 : alarmId;
                          if (mySelectedEvents[DateTime.parse(date)] != null) {
                            mySelectedEvents[DateTime.parse(date)]?.add(
                                MyEvents(
                                    eventTitle: titleController.text,
                                    eventDescp: descpController.text,
                                    alarm: dateController.text,
                                    alarmId: localAlarmId));
                          } else {
                            mySelectedEvents[DateTime.parse(date)] = [
                              MyEvents(
                                  eventTitle: titleController.text,
                                  eventDescp: descpController.text,
                                  alarm: dateController.text,
                                  alarmId: localAlarmId)
                            ];
                          }
                        });

                        //アラームの設定があるか
                        if (dateController.text != "") {
                          myAlarm.add(MyAlarm(
                              alarmId: alarmId,
                              alarmTitle: titleController.text,
                              alarmSubTitle: descpController.text,
                              alarmDate: dateController.text,
                              status: 0));
                          scheduleAlarm(DateTime.parse(dateController.text),
                              titleController.text, alarmId);
                          alarmId++;
                        }
                        print("添加后的闹钟ID${alarmId}");
                        mySelectedEvents.forEach((key, value) {
                          var date = DateFormat('yyyy-MM-dd').format(key);
                          _events[DateTime.parse(date)] = value;
                        });
                        prefs.setString(
                            "events", json.encode(encodeMap(_events)));

                        //アラーム保存
                        List<String> events = myAlarm
                            .map((f) => json.encode(f.toJson()))
                            .toList();
                        prefs.setString("myAlarm", json.encode(events));
                        print(json.encode(encodeMap(_events)));
                        print(events);
                        //入力した内容をクリアする
                        titleController.clear();
                        descpController.clear();
                        dateController.clear();
                        visible = false;
                        Navigator.pop(context);
                        return;
                      }
                    },
                    child: const Text('確認'),
                  ),
                ],
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(centerTitle: true, title: Text("カレンダー"), actions: <Widget>[
          IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddEventDialog();
              }),
        ]),
        body: SingleChildScrollView(
            child: Column(children: [
          Card(
            margin: EdgeInsets.all(15.0),
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
                //     TextStyle(color: Colors.pink, fontSize: 16.0),
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
                weekendStyle: TextStyle(color: Colors.pink),
              ),
              // Calendar Dates styling
              calendarStyle: const CalendarStyle(
                // Weekend dates color (Sat & Sun Column)
                weekendTextStyle: TextStyle(color: Colors.pink),
                // highlighted color for today
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                // highlighted color for selected day
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration:
                    BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
              ),
              selectedDayPredicate: (currentSelectedDate) {
                // as per the documentation 'selectedDayPredicate' needs to determine
                // current selected day
                return (isSameDay(selectedCalendarDate!, currentSelectedDate));
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
          // ListView(
          //   shrinkWrap: true,
          //   children:
          ..._listOfDayEvents(selectedCalendarDate!).map((myEvents) => Padding(
              padding: const EdgeInsets.all(5),
              child: ListTile(
                onTap: () {},
                // leading: const Icon(
                //   Icons.access_alarms_sharp,
                //   color: Colors.black,
                // ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
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
                      var index = _listOfDayEvents(selectedCalendarDate!)
                          .indexOf(myEvents);
                      var alramIndex = 0;
                      var alramId = 0;
                      if (_listOfDayEvents(selectedCalendarDate!)[index]
                              .alarm !=
                          "") {
                        alramId = _listOfDayEvents(selectedCalendarDate!)[index]
                            .alarmId!;
                        print(alramId);
                        alramIndex = myAlarm.indexWhere(
                            (element) => element.alarmId == alramId);
                        print(alramIndex);
                        myAlarm.removeAt(alramIndex);
                      }

                      setState(() {
                        _listOfDayEvents(selectedCalendarDate!).removeAt(index);
                      });
                      //アラームの削除
                      await flutterLocalNotificationsPlugin.cancel(alramId);
                      //还要删除对应的MAp的时间
                      prefs.setString(
                          "events", json.encode(encodeMap(mySelectedEvents)));
                      List<String> events =
                          myAlarm.map((f) => json.encode(f.toJson())).toList();
                      prefs.setString("myAlarm", json.encode(events));
                      print(events);
                    },
                    icon: Icon(Icons.delete)),
              )))
          //.toList(),
          //)
        ])));
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 5,
      bottom: 5,
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
    'Channel for Alarm notification',
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
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  print(scheduledNotificationDateTime);
  await flutterLocalNotificationsPlugin.schedule(
    id,
    'リマインド!',
    alarmInfo + "の時間だよ!",
    scheduledNotificationDateTime,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
  );
}
