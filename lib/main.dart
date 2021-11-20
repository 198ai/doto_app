import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'pages/tabs/Tabs.dart';

import 'routers/router.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      designSize: Size(428, 926),
      builder: () =>MaterialApp(      
     //home: Tabs(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute:onGenerateRoute
    ));
  }
}