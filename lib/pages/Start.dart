import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  StartPage({Key? key}) : super(key: key);

  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("スタート"),
      ),
      body: Text('スタートbody'),
    );
  }
}