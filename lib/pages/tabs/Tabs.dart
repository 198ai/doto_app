import 'package:flutter/material.dart';

import 'ToDoList.dart';
import 'Calendar.dart';
import 'Count.dart';
import 'Group.dart';

class Tabs extends StatefulWidget {
  Tabs({Key? key}) : super(key: key);

  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;
  String _titleName = "";
  List _pageList = [ToDoListPage(), CalendarPage(), CountPage(), GroupPage()];
  List<String> _title = ["アジェンダ", "カレンダー", "統計", "グループ"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this._titleName),
      ),
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
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: UserAccountsDrawerHeader(
                    accountName: Text("未登録/サインイン"),
                    accountEmail: Text("メールアドレス"),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage("https://www.itying.com/images/flutter/3.png")
                    ),
                    decoration:BoxDecoration(                        
                        image: DecorationImage(
                          image: NetworkImage("https://www.itying.com/images/flutter/2.png"),
                          fit:BoxFit.cover,
                        )
                    ),
                  ),
                    ),
                ),
               
                // Expanded(
                //   child: UserAccountsDrawerHeader(
                //     accountName: Text("未登録/サインイン"),
                //     accountEmail: Text("メールアドレス"),
                //     currentAccountPicture: CircleAvatar(
                //       backgroundImage: NetworkImage("https://www.itying.com/images/flutter/3.png")
                //     ),
                //     decoration:BoxDecoration(                        
                //         image: DecorationImage(
                //           image: NetworkImage("https://www.itying.com/images/flutter/2.png"),
                //           fit:BoxFit.cover,
                //         )
                //     ),
                //   ),
                // ),
              ],
            ),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.help_outline_sharp,color: Colors.yellow[50])),
              title: Text("ヘルプ"),
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.settings_sharp)),
              title: Text("設定"),
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.markunread_outlined)),
              title: Text("連絡先"),
            ),
          ],
        ),
      ),
    );
  }
}
