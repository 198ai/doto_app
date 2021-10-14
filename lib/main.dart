import 'package:flutter/material.dart';

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
    return MaterialApp(      
      // home: Tabs(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/task',
      onGenerateRoute:onGenerateRoute
    );
  }
}