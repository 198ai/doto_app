import 'package:flutter/material.dart';
import '../pages/tabs/Tabs.dart';
import '../screens/tasks/tasks.dart';
import '../pages/Start.dart';
import '../pages/Login.dart';
//ルーティング
final Map<String,Function> routes = {
  '/': (context) => Tabs(),
  '/start': (context) => StartPage(),
  '/login': (context) => LoginPage(),
  '/task' :(context)=> Tasks(),
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
