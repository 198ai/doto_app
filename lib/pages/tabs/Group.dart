import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  GroupPage({Key? key}) : super(key: key);

  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          centerTitle: true,
          //title: Text(_strTitle, style: TextStyle(color: commonStrColor)), //AIForce Equipment App
          title: Text('グループ'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
                child: Column(children: [
              Container(
                  height: ScreenAdapter.height(80),
                  width: ScreenAdapter.width(600),
                  child: Text("123"))
            ]))));
  }
}
