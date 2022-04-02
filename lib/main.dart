import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doto_app/pages/tabs/Tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'pages/tabs/Tabs.dart';
import 'package:doto_app/model/myevents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'model/userData.dart';
import 'routers/router.dart';
import 'services/ScreenAdapter.dart';

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
          (int id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
     android: initializationSettingsAndroid, iOS:initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  runApp(MyApp());
  //initializeDateFormatting().then((_) => runApp(MyApp()));
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
  late SharedPreferences prefs;
  late UserData userdata;
  late String userName;
  late String userEmail;
 @override
  void initState() {
    super.initState();
    Future(() async {
     SharedPreferences retult = await SharedPreferences.getInstance();
      //获取user token
      retult.getString("userdata") == null
          ? userdata = UserData(name: "", email: "", accessToken: "")
          : userdata =
              UserData.fromJson(json.decode(retult.getString("userdata")));
      if (userdata.accessToken != "") {
        prefs = await SharedPreferences.getInstance();
       await loginFunction();
      }
    });
  }
  loginFunction() async {
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    try {
      Response response =
        await dio.get("http://www.leishengle.com/api/v1/user");
      // Response response =
      //     await Dio().post("http://10.0.2.2:8000/api/v1/login", data:params);
      if (response.statusCode == 500) {
        prefs.remove("userdata");
      }
    } on DioError catch (e) {
      if (e.response.statusCode == 500) {
        prefs.remove("userdata");
      }
    }
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
           localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('ja')
            ],
          //   //home: Tabs(),
            home: Splash2(),
            navigatorObservers: [MyApp.routeObserver], //添加路由观察者
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            onGenerateRoute: onGenerateRoute));
  }
}
class Splash2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: new Tabs(),
      title: new Text('美らじぇんだ\n目標達成までちゃ～まじゅん！',textScaleFactor: 1.8,textAlign: TextAlign.center,style:TextStyle(fontSize:ScreenAdapter.size(15),fontWeight:FontWeight.bold) ,),
      image: Image.asset("images/ic_launcher.png"),
        loadingText: Text("Loading"),
      photoSize: 40.0,
      loaderColor: Colors.green,
    );
  }
}

