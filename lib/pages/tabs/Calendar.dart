import 'dart:collection';

import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:doto_app/pages/tabs/Calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  _CalendarPageState createState() => _CalendarPageState();
}

class EventModel {
  EventModel({
    required this.events,
  });

  List<MyEvents> events;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        events: List<MyEvents>.from(
            json["Events"].map((x) => MyEvents.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Events": List<dynamic>.from(events.map((x) => x.toJson())),
      };
}

class MyEvents {
  final String eventTitle;
  final String eventDescp;
  MyEvents({required this.eventTitle, required this.eventDescp});

  @override
  String toString() => eventTitle;
  factory MyEvents.fromJson(Map<String, dynamic> json) => MyEvents(
        eventTitle: json["eventTitle"],
        eventDescp: json["eventDescp"],
      );

  Map<String, dynamic> toJson() => {
        "eventTitle": eventTitle,
        "eventDescp": eventDescp,
      };
}

class _CalendarPageState extends State<CalendarPage> {
  final todaysDate = DateTime.now();
  var _focusedCalendarDate = DateTime.now();
  final _initialCalendarDate = DateTime(2000);
  final _lastCalendarDate = DateTime(3000);
  DateTime? selectedCalendarDate;
  final titleController = TextEditingController();
  final descpController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<MyEvents>> mySelectedEvents;
  late Map setData;
  List setdate = [];
  late Map<DateTime, List<MyEvents>> _events; //ローカルに保存用
  late SharedPreferences prefs;
  List<MyEvents> list = [];
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
    //print(map);
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

  @override
  void dispose() {
    titleController.dispose();
    descpController.dispose();
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
        builder: (context) => AlertDialog(
              title: const Text('リマインド'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTextField(controller: titleController, hint: 'タイトル'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  buildTextField(controller: descpController, hint: 'メモ'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () async {
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
                        if (mySelectedEvents[selectedCalendarDate] != null) {
                          mySelectedEvents[selectedCalendarDate]?.add(MyEvents(
                              eventTitle: titleController.text,
                              eventDescp: descpController.text));
                        } else {
                          mySelectedEvents[selectedCalendarDate!] = [
                            MyEvents(
                                eventTitle: titleController.text,
                                eventDescp: descpController.text)
                          ];
                        }
                      });
                      //mySelectedEvents = {};
                      //print("添加后的列表$mySelectedEvents");

                      mySelectedEvents.forEach((key, value) {
                        value.isNotEmpty ? _events[key] = value : null;
                      });
                      //mySelectedEvents = {};
                      prefs.setString(
                          "events", json.encode(encodeMap(_events)));
                      print("保存的时候$_events");
                      // _events = decodeMap(
                      //     json.decode(prefs.getString("events") ?? "{}"));
                      // print(_events);
                      titleController.clear();
                      descpController.clear();
                      Navigator.pop(context);
                      return;
                    }
                  },
                  child: const Text('確認'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    print(mySelectedEvents[selectedCalendarDate]);
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
              side: BorderSide(color: Colors.white, width: 2.0),
            ),
            child: TableCalendar(
              //今日の時間
              focusedDay: _focusedCalendarDate,
              // 2000年から
              firstDay: _initialCalendarDate,
              // 3000年まで
              lastDay: _lastCalendarDate,
              calendarFormat: _calendarFormat,
              weekendDays: [DateTime.sunday, 6],
              startingDayOfWeek: StartingDayOfWeek.monday,
              daysOfWeekHeight: 40.0,
              rowHeight: 60.0,
              //eventLoader: _listOfDayEvents,
              eventLoader: _listOfDayEvents,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0),
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
                  size: 28,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 28,
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
          ListView(
            shrinkWrap: true,
            children: _listOfDayEvents(selectedCalendarDate!)
                .map((myEvents) => ListTile(
                      onTap: () {},
                      leading: const Icon(
                        Icons.access_alarms_sharp,
                        color: Colors.black,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('タイトル:   ${myEvents.eventTitle}'),
                      ),
                      subtitle: Text('メモ:   ${myEvents.eventDescp}'),
                      trailing: IconButton(
                          onPressed: () {
                            var index = _listOfDayEvents(selectedCalendarDate!)
                                .indexOf(myEvents);
                            setState(() {
                              _listOfDayEvents(selectedCalendarDate!)
                                  .removeAt(index);
                            });
                            //还要删除对应的MAp的时间
                            prefs.setString("events",
                                json.encode(encodeMap(mySelectedEvents)));
                          },
                          icon: Icon(Icons.delete)),
                    ))
                .toList(),
          )
        ])));
  }
}
