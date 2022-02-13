import 'dart:async';

import 'package:doto_app/model/tasklist.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class HasDonePage extends StatefulWidget {
  String hasdone;
  HasDonePage({this.hasdone = ""});

  _HasDonePageState createState() => _HasDonePageState(this.hasdone);
}

class _HasDonePageState extends State<HasDonePage> {
  List<TodoModel> hasdone = [];
  List<String> done = [];
  List<String> todos = [];
  int id = 0;
  final String getdone; // 声明接收到值
  _HasDonePageState(this.getdone) : super(); // 通过这段代码接收从父组件传递过来的值
  @override
  void initState() {
    super.initState();
    if (getdone != "") {
      // TodoModel item = TodoModel(id: id++, title: getdone, complete: true);
      // setState(() {
      //   hasdone.add(item);
      // });
    }
    Future(() async {
      SharedPreferences retult = await SharedPreferences.getInstance();
      retult.getStringList("done") == null
          ? done = []
          : done = retult.getStringList("done");
      print(done);
      if (done != []) {
        done.forEach((done) {
          // TodoModel item = TodoModel(
          //   id: id++,
          //   title: done,
          //   complete: true,
          // );
          // setState(() {
          //   hasdone.add(item);
          // });
        });
      }
      _listView();
    });
  }

  //LIST削除する時、
  void deleteTodo(index) async {
    SharedPreferences list = await SharedPreferences.getInstance();
    List<TodoModel> newTodos = hasdone;
    newTodos.remove(newTodos[index]);
    done.removeAt(index);
    setState(() {
      hasdone = newTodos;
      list.setStringList("done", done);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: AppBar(
             backgroundColor: Colors.green,
              centerTitle: true, title: Text("完成アジェンダ"), actions: <Widget>[]),
          preferredSize: Size.fromHeight(ScreenAdapter.height(61)),
        ),
        body: new Column(children: <Widget>[
          SizedBox(height: ScreenAdapter.height(8)),
          Expanded(child: _listView()),
        ]));
  }

  ListView _listView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        TodoModel item = hasdone[index];
        return _normalCard(item, index);
      },
      itemCount: hasdone.length,
      padding: EdgeInsets.all(3),
    );
  }

  GestureDetector _normalCard(item, index) {
    return GestureDetector(
        onLongPressStart: (details) async {
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate(
              duration: 100,
            );
          }
          SharedPreferences list = await SharedPreferences.getInstance();
          int selected = await showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.delete),
                    Text(("削除")),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.border_color_outlined),
                    Text("未完成に"),
                  ],
                ),
              ), // Me// Menu Item
            ],
          );
          if (selected == 0) {
            setState(() {
              hasdone.removeAt(index);
              done.removeAt(index);
              list.setStringList("done", done);
            });
          } else if (selected == 1) {
            setState(() {
              setState(() {
               todos.add(hasdone[index].title);
                list.setStringList("todos", todos);
                hasdone.removeAt(index);
                done.removeAt(index);
                list.setStringList("done", done);
              });
            });
          }
        },
        child: Card(
          elevation: 15.0, //设置阴影
          margin: EdgeInsets.only(
              top: ScreenAdapter.height(25),
              left: ScreenAdapter.width(21),
              right: ScreenAdapter.width(21)),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0))), //设置圆角
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.title}', //'标题'
                    style: item.complete
                        ? TextStyle(
                            decorationColor: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            fontSize: ScreenAdapter.size(35),
                            color: Color.fromRGBO(16, 16, 16, 1),
                            fontWeight: FontWeight.bold)
                        : TextStyle(
                            fontSize: ScreenAdapter.size(35),
                            color: Color.fromRGBO(16, 16, 16, 1),
                            fontWeight: FontWeight.bold),
                  ),
                  // subtitle: new Text('子标题'),
                  TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    child: Text(
                      "スタート",
                      style: TextStyle(
                          fontSize: ScreenAdapter.size(20),
                          color: Color.fromARGB(74, 16, 16, 16),
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/start');
                    },
                  ),
                ]),
          ),
        ));
  }
}
