import 'dart:async';
import 'package:doto_app/pages/HasDone.dart';
import 'package:doto_app/widget/dialog.dart';
import 'package:doto_app/widget/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/tasklist.dart';
import '../../services/ScreenAdapter.dart';
//ローカルストレージ保存するため
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class ToDoListPage extends StatefulWidget {
  ToDoListPage({Key? key}) : super(key: key);

  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<TodoModel> todos = [];
  List<String> storge = [];
  List<String> done = [];
  int id = 0;
  var _chooseTime;
  var _chooseDate;
  final textController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  void _printLatestValue() {
    print('Second text field: ${textController.text}');
  }

  void _printTimeValue() {
    print('Second text field: ${timeController.text}');
  }

  @override
  void initState() {
    super.initState();
    //追加ポップアップに書いた内容を記録
    textController.addListener(_printLatestValue);
    timeController.addListener(_printTimeValue);
    dateController.addListener(() {
      print(dateController.text);
    });
    //ローカルストレージから、値をLISTに渡す、初期化する
    Future(() async {
      SharedPreferences retult = await SharedPreferences.getInstance();
      retult.getStringList("todos") == null
          ? storge = []
          : storge = retult.getStringList("todos");
      print(storge);

      if (storge != []) {
        storge.forEach((e) {
          TodoModel item = TodoModel(
            id: id++,
            title: e,
            complete: false,
          );
          setState(() {
            todos.add(item);
          });
        });
      }
      _listView();
    });
  }

//違う画面へ行くとき、今の画面を破棄して、追加TEXT記録も破棄
  @override
  void dispose() {
    textController.dispose();
    timeController.dispose();
    dateController.dispose();
    super.dispose();
  }

//ToDoListのCard内容はポップアップから渡されている
  _editParentText(editText) async {
    TodoModel item = TodoModel(
      id: id++,
      title: editText,
      complete: false,
    );
    //画面をリロードして、新たな項目を表示する
    setState(() {
      todos.add(item);
      storge.add(item.title);
    });
    //ローカルにLISTを保存する
    SharedPreferences list = await SharedPreferences.getInstance();
    list.setStringList("todos", storge);
  }

  //LIST削除する時、
  void deleteTodo(index) async {
    SharedPreferences list = await SharedPreferences.getInstance();
    List<TodoModel> newTodos = todos;
    newTodos.remove(newTodos[index]);
    storge.removeAt(index);
    setState(() {
      todos = newTodos;
      list.setStringList("todos", storge);
    });
  }

  //時間の選択
  _showDatePicker() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'キャンセル',
                      style: TextStyle(fontSize: 13),
                    )),
                // ignore: deprecated_member_use
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '確認',
                      style: TextStyle(fontSize: 13),
                    )),
              ],
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date, //这里改模式
                onDateTimeChanged: (dateTime) {
                  print("${dateTime.year}-${dateTime.month}-${dateTime.day}");
                  var startDate =
                      new DateTime(dateTime.year, dateTime.month, dateTime.day);
                  var endDate = new DateTime.now();
                  var days = startDate.difference(endDate).inDays;
                  dateController.text = days.toString() + "日";
                },
              ),
            ),
          ]);
        }).whenComplete(() {});
  }

  String _formatDateTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    timeController.text =
        """${_convertTwoDigits(hour) + "時間"}:${_convertTwoDigits(minute) + "分"}""";
    return timeController.text;
  }

  String _convertTwoDigits(int number) {
    return number >= 10 ? "$number" : "0$number";
  }

  Future _showTimePicker() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'キャンセル',
                      style: TextStyle(fontSize: 13),
                    )),
                // ignore: deprecated_member_use
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '確認',
                      style: TextStyle(fontSize: 13),
                    )),
              ],
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoTimerPicker(
                initialTimerDuration: Duration(hours: 0, minutes: 0),
                mode: CupertinoTimerPickerMode.hm,
                onTimerDurationChanged: (Duration changedtimer) {
                  setState(() {
                    _formatDateTime(changedtimer.inSeconds);
                    //_chooseTime = _chooseTime.substring(0,_chooseTime.length-10);
                  });
                },
              ),
            ),
          ]);
        }).whenComplete(() {});
  }

//画面のHTML
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          child:
              AppBar(centerTitle: true, title: Text("アジェンダ"), actions: <Widget>[
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.add),
              onPressed: () {
                //足すボダン押した時、ポップアップが出ます
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          color: Colors.white,
                          width: 50,
                          height: 300,
                          child: Center(
                            child: SingleChildScrollView(
                                child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(30, 5, 30, 0),
                                    child: Text("新たな挑戦を始めるね！＾-＾素晴らしい！")),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                  child: TextField(
                                    style: TextStyle(color: Colors.black87),
                                    controller: textController,
                                    decoration: InputDecoration(
                                        icon:Icon(Icons.article_outlined) ,
                                        labelText: "タスク名称",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        )),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                    child: TextField(
                                        decoration: new InputDecoration(
                                          icon: Icon(Icons.access_time),
                                          hintText: "時間選択",
                                        ),
                                        controller: timeController,
                                        onTap: () {
                                          _showTimePicker();
                                        })),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                                    child: TextField(
                                        decoration: new InputDecoration(
                                          icon: Icon(
                                              Icons.calendar_today_outlined),
                                          hintText: "完成予定日選択",
                                        ),
                                        controller: dateController,
                                        onTap: () {
                                          _showDatePicker();
                                        })),
                                Container(
                                  height: btnHeight,
                                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              textController.text = "";
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "サボる",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  _editParentText(
                                                      textController.text);
                                                });
                                              },
                                              child: Text(
                                                "チャレンジする",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                          ),
                        ),
                      );
                    });
              },
            ),
          ]),
          preferredSize: Size.fromHeight(ScreenAdapter.height(61)),
        ),
        drawer: drawerEX(),
        body: new Column(children: <Widget>[
          SizedBox(height: ScreenAdapter.height(8)),
          Expanded(child: _listView()),
        ]));
  }

  ListView _listView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        TodoModel item = todos[index];
        return _normalCard(item, index);
      },
      itemCount: todos.length,
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
                    Icon(Icons.check),
                    Text("完成"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.assignment_turned_in_outlined),
                    Text("完成へ"),
                  ],
                ),
              ), // Me// Menu Item
            ],
          );
          if (selected == 0) {
            setState(() {
              todos.removeAt(index);
              storge.removeAt(index);
              list.setStringList("todos", storge);
            });
          } else if (selected == 1) {
            setState(() {
              list.getStringList("done") == null
                  ? done = []
                  : done = list.getStringList("done");
              done.add(todos[index].title);
              list.setStringList("done", done);
              todos.removeAt(index);
              storge.removeAt(index);
              list.setStringList("todos", storge);
            });
          } else if (selected == 2) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HasDonePage()));
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
                    style: TextStyle(
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
