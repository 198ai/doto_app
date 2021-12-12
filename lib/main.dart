import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'pages/tabs/Tabs.dart';
import 'package:doto_app/model/myevents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routers/router.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //タイマー設定
  List<MyEvents> list = [];
  late Map<DateTime, List<MyEvents>> _events;
  late SharedPreferences prefs;
  late Map<DateTime, List<MyEvents>> mySelectedEvents;

 @override
  void initState() {
    mySelectedEvents = {};
    _events = {};
    super.initState();
    Future(() async {
      prefs = await SharedPreferences.getInstance();
      mySelectedEvents = decodeMap(json.decode(prefs.getString("events") ?? "{}"));
      //アラーム初期設定
      mySelectedEvents.forEach((key, value) {
        value.forEach((element) {
          if (element.alarm != "") {
            scheduleAlarm(DateTime.parse(element.alarm), element.eventTitle);
          }
       });
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(428, 926),
        builder: () => MaterialApp(
            //home: Tabs(),
            navigatorObservers: [MyApp.routeObserver], //添加路由观察者
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            onGenerateRoute: onGenerateRoute));
  }
}


void scheduleAlarm(
    DateTime scheduledNotificationDateTime, String alarmInfo) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    'Channel for Alarm notification',
    icon: 'ic_launcher',
    sound: RawResourceAndroidNotificationSound('clock'),
    largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
  );

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'clock.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true);
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.schedule(
      0,
      'リマインド!',
      alarmInfo + "の時間だよ!",
      scheduledNotificationDateTime,
      platformChannelSpecifics);
}
