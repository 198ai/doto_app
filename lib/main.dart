import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'pages/tabs/Tabs.dart';

import 'routers/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      designSize: Size(428, 926),
      builder: () =>MaterialApp(      
     //home: Tabs(),
      navigatorObservers: [MyApp.routeObserver], //添加路由观察者
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute:onGenerateRoute
    ));
  }
}