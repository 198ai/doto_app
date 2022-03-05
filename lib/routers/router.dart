import 'package:doto_app/pages/Countdown.dart';
import 'package:doto_app/pages/ForgotPassword.dart';
import 'package:doto_app/pages/HasDone.dart';
import 'package:doto_app/pages/ResetPassword.dart';
import 'package:doto_app/pages/SignUp.dart';
import 'package:doto_app/pages/tabs/ToDoList.dart';
import 'package:flutter/material.dart';
import '../pages/tabs/Tabs.dart';
import '../pages/Start.dart';
import '../pages/Login.dart';
//ルーティング
final Map<String,Function> routes = {
  '/': (context) => Tabs(),
  '/start': (context) => StartPage(),
  '/hasdone':(context)=>HasDonePage(),
  '/login': (context) => LoginPage(),
  '/countdown': (context) =>CountDown(),
  '/signup':(context)=>SignUpPage(),
  '/forgotpassword':(context)=>ForgotPassword(),
  '/resetPassword':(context)=>ResetPassword(),
};


var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final Function? pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
