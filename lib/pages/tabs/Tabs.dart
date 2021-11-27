import 'package:flutter/material.dart';

import 'ToDoList.dart';
import 'Calendar.dart';
import 'Count.dart';
import 'Group.dart';

class Tabs extends StatefulWidget {
  Tabs({Key? key,this.tabSelected = 0}) : super(key: key);
  int tabSelected;
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  String _titleName = "";
  List _pageList = [ToDoListPage(), CalendarPage(), CountPage(), GroupPage()];
  List<String> _title = ["アジェンダ", "カレンダー", "統計", "グループ"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._titleName = this. _title[this._currentIndex];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(this._titleName),
      // ),
      body: this._pageList[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: this._currentIndex,
        onTap: (index) {
          setState(() {
            this._currentIndex = index;
            this._titleName = this. _title[this._currentIndex];
          });
        },
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.red,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined), label: "アジェンダ"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "カレンダー"),
          BottomNavigationBarItem(
              icon: Icon(Icons.addchart_sharp), label: "統計"),
          // BottomNavigationBarItem(icon: Icon(Icons.people), label: "グループ")
        ],
      ),
    );
  }
}
