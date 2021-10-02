import 'package:flutter/material.dart';
import '../pages/tabs/Tabs.dart';

import '../pages/Start.dart';

//ルーティング
final Map<String,Function> routes = {
  '/': (context) => Tabs(),
  '/start': (context) => StartPage(),
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
