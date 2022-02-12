import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:doto_app/model/ringtonePlayer.dart';
import 'package:doto_app/model/userData.dart';
import 'package:doto_app/pages/Countdown.dart';
import 'package:doto_app/pages/HasDone.dart';
import 'package:doto_app/pages/tabs/Calendar.dart';
import 'package:doto_app/widget/dialog.dart';
import 'package:doto_app/widget/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../model/tasklist.dart';
import '../../services/ScreenAdapter.dart';
//ローカルストレージ保存するため
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../Start.dart';

class ToDoListPage extends StatefulWidget {
  int time;
  ToDoListPage({Key? key, this.time = 0}) : super(key: key);

  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> with RouteAware {
  List<TodoModel> todos = [];
  List storge = []; //ローカルから取り出した値をここに
  List<String> done = [];
  String _time = "";
  int id = 0;
  late int days;
  late int inSeconds;
  late String enddate;
  final textController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();
  late UserData userdata;
  late String userName;
  late String userEmail;
  var _isFocus = false;
  void _printLatestValue() {
    print('Second text field: ${textController.text}');
  }

  void _printTimeValue() {
    print('Second text field: ${timeController.text}');
  }

  Future gettodolist() async {
    ///本地存储的数据先更新给API，同步数据
    ///然后更新本地数据
    SharedPreferences retult = await SharedPreferences.getInstance();
    Dio dio = new Dio();
    List jsonData;
    TodoModel data;
    dio.options.headers['content-Type'] = 'application/json';
    print("Bearer ${userdata.accessToken}");

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";

    Response response = await dio.get("http://10.0.2.2:8000/api/v1/todolist");

    jsonData = response.data;
    //data = TodoModel.fromJson(response.data);
    jsonData.forEach((element) {
      print(element);
      todos.add(TodoModel.fromJson(element));
      //从API中拿到数据后
      //本地存储
      //然后添加
    });
  }

  @override
  void didChangeDependencies() {
    MyApp.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute); //订阅
    super.didChangeDependencies();
  }

  @override
  void didPopNext() async {
    debugPrint("------>アジェンダ画面に戻った");
    super.didPopNext();
    todos = [];
    Future(() async {
      SharedPreferences retult = await SharedPreferences.getInstance();
      if (retult.getString("toDoList") != null) {
        storge.addAll(json.decode(retult.getString("toDoList") ?? "{}"));
      }
      storge.forEach((e) {
        todos.add(TodoModel.fromJson(json.decode(e)));
      });
      setState(() {
        _listView();
      });
    });
  }

  @override
  void didPushNext() {
    super.didPushNext();
    // 当前页面push到其他页面走这里
    debugPrint("------>アジェンダ画面から出る");
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
      retult = await SharedPreferences.getInstance();
      retult.getString("userdata")==null?userdata=UserData(name: "", email: "", accessToken: ""):
      userdata = UserData.fromJson(json.decode(retult.getString("userdata")));
      //await gettodolist();
      if (retult.getString("toDoList") != null) {
        storge.addAll(json.decode(retult.getString("toDoList") ?? "{}"));
      }
      storge.forEach((e) {
        //画面リロード
        todos.add(TodoModel.fromJson(json.decode(e)));
        todos.forEach((e) async {
          await dateChange(e.endDate);
        });
      });
      if (retult.getString("userdata") != null) {
        userdata = UserData.fromJson(json.decode(retult.getString("userdata")));
      } else {
        userdata = UserData(name: "", email: "", accessToken: "");
      }
      userName = userdata.name == "" ? "" : userdata.name;
      userEmail = userdata.email == "" ? "" : userdata.email;
      setState(() {
        _listView();
      });
    });
  }

  //日付変更検査
  dateChange(String date) async {
    //String から時間に変換
    DateFormat inputFormat = DateFormat('yyyy-MM-dd');
    DateTime input = inputFormat.parse(date);
    var startDate = new DateTime(input.year, input.month, input.day);
    var endDate = new DateTime.now();
    setState(() {
      //完成するまでの日付更新
      todos.forEach((e) {
        e.date = ((startDate.difference(endDate).inDays) + 1).toString();
      });
    });
  }

//違う画面へ行くとき、今の画面を破棄して、追加TEXT記録も破棄
  @override
  void dispose() {
    textController.dispose();
    timeController.dispose();
    dateController.dispose();
    MyApp.routeObserver.unsubscribe(this); //取消订阅
    super.dispose();
  }

//ToDoListのCard内容はポップアップから渡されている
  _editParentText(String editText, String getdate, String gettime,
      String getendDate) async {
    TodoModel item = TodoModel(
      id: id++,
      title: editText,
      date: getdate,
      time: gettime,
      complete: 0,
      endDate: getendDate,
    );
    //画面をリロードして、新たな項目を表示する
    setState(() {
      todos.add(item);
    });
    //ローカルにLISTを保存する
    SharedPreferences list = await SharedPreferences.getInstance();
    List<String> events = todos.map((f) => json.encode(f.toJson())).toList();
    list.setString("toDoList", json.encode(events));
  }

  //用户名输入框的焦点控制
  FocusNode _dateFocusNode = new FocusNode();
  FocusNode _timeFocusNode = new FocusNode();

  void hindKeyBoarder() {
    //输入框失去焦点
    _dateFocusNode.unfocus();
    _timeFocusNode.unfocus();

    //隐藏键盘
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  addtodolist(String editText, String getdate, String gettime,
      String getendDate) async {
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    print("Bearer ${userdata.accessToken}");
    var params = {
      "title": editText,
      "complete": 0,
      "time": gettime,
      "date": getdate,
      "endDate": getendDate,
      "status": 0
    };

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";

    Response response =
        await dio.post("http://10.0.2.2:8000/api/v1/addtodolist", data: params);
    print(response);
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
                      style: TextStyle(fontSize: ScreenAdapter.size(13), color: Colors.green),
                    )),
                // ignore: deprecated_member_use
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '確認',
                      style: TextStyle(fontSize: ScreenAdapter.size(13), color: Colors.green),
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
                  days = ((startDate.difference(endDate).inDays) + 1);
                  enddate =
                      "${dateTime.year}-${dateTime.month}-${dateTime.day}";
                  dateController.text = days.toString() + "日";
                },
              ),
            ),
          ]);
        }).whenComplete(() async {});
  }

  String _formatDateTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    _time =
        """${_convertTwoDigits(hour) + "時間"}${_convertTwoDigits(minute) + "分"}""";

    return _time;
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
                      style: TextStyle(fontSize: ScreenAdapter.size(13), color: Colors.green),
                    )),
                // ignore: deprecated_member_use
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '確認',
                      style: TextStyle(fontSize: ScreenAdapter.size(13), color: Colors.green),
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
                    // _formatDateTime(changedtimer.inSeconds);
                    timeController.text =
                        _formatDateTime(changedtimer.inSeconds);
                    inSeconds = changedtimer.inSeconds;
                    //_chooseTime = _chooseTime.substring(0,_chooseTime.length-10);
                  });
                },
              ),
            ),
          ]);
        }).whenComplete(() async {});
  }

//画面のHTML
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          child:
              AppBar(centerTitle: true, title: Text("アジェンダ"), backgroundColor: Colors.green, actions: <Widget>[
            IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.add),
              onPressed: () {
                textController.text = "";
                dateController.text = "";
                timeController.text = "";
                //足すボダン押した時、ポップアップが出ます
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          color: Colors.white,
                          width: ScreenAdapter.width(250),
                          height: ScreenAdapter.height(430),
                          child: Center(
                            child: SingleChildScrollView(
                                child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      ScreenAdapter.width(30),
                                      ScreenAdapter.height(30),
                                      ScreenAdapter.width(30),
                                      ScreenAdapter.height(30)),
                                  child: Column(
                                    children: [
                                      Text("新たな挑戦を始めるね！"),
                                      Text("＾-＾素晴らしい！")
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      ScreenAdapter.width(30),
                                      ScreenAdapter.height(0),
                                      ScreenAdapter.width(30),
                                      ScreenAdapter.height(0)),
                                  child: TextField(
                                    controller: textController,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        icon: Icon(Icons.article_outlined, color: Colors.green),
                                        labelText: "タスク名称",
                                        labelStyle: TextStyle(
                                          color: _isFocus ? Colors.green : Colors.grey,
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.green),
                                        )),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenAdapter.width(30),
                                        ScreenAdapter.height(0),
                                        ScreenAdapter.width(30),
                                        ScreenAdapter.height(0)),
                                    child: TextField(
                                        cursorColor: Colors.green,
                                        decoration: new InputDecoration(
                                          icon: Icon(Icons.access_time, color: Colors.green),
                                          hintText: "時間選択",
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide:
                                              BorderSide(color: Colors.green),
                                            )
                                        ),
                                        controller: timeController,
                                        onTap: () async {
                                          await _showTimePicker();
                                        })),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        ScreenAdapter.width(30),
                                        ScreenAdapter.height(0),
                                        ScreenAdapter.width(30),
                                        ScreenAdapter.height(0)),
                                    child: TextField(
                                        cursorColor: Colors.green,
                                        decoration: new InputDecoration(
                                          icon: Icon(
                                              Icons.calendar_today_outlined, color: Colors.green),
                                          hintText: "完成予定日選択",
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide:
                                              BorderSide(color: Colors.green),
                                            )
                                        ),
                                        controller: dateController,
                                        onTap: () {
                                          _showDatePicker();
                                        })),
                                Container(
                                  height: btnHeight,
                                  margin: EdgeInsets.fromLTRB(
                                      ScreenAdapter.width(30),
                                      ScreenAdapter.height(0),
                                      ScreenAdapter.width(30),
                                      ScreenAdapter.height(0)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              textController.text = "";
                                              dateController.text = "";
                                              timeController.text = "";
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "サボる",
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenAdapter.size(15),
                                                  color: Colors.green),
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () async {
                                                setState(() {
                                                  if (textController.text == "" &&
                                                      dateController.text ==
                                                          "" &&
                                                      timeController.text ==
                                                          "") {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            '全ての内容を入力してください'),
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );
                                                    //Navigator.pop(context);
                                                    return;
                                                  } else {
                                                    addtodolist(
                                                        textController.text,
                                                        days.toString(),
                                                        inSeconds.toString(),
                                                        enddate.toString());
                                                    _editParentText(
                                                        textController.text,
                                                        days.toString(),
                                                        inSeconds.toString(),
                                                        enddate.toString());
                                                    Navigator.of(context).pop();
                                                  }
                                                });
                                              },
                                              child: Text(
                                                "チャレンジする",
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenAdapter.size(15),
                                                    color: Colors.green),
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
          //実機振動機能、エミュレータの時、コミットアウトする
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
              List<String> events =
                  todos.map((f) => json.encode(f.toJson())).toList();
              list.setString("toDoList", json.encode(events));
            });
          } else if (selected == 1) {
            setState(() {
              list.getStringList("done") == null
                  ? done = []
                  : done = list.getStringList("done");
              done.add(todos[index].title);
              list.setStringList("done", done);
              todos.removeAt(index);
              List<String> events =
                  todos.map((f) => json.encode(f.toJson())).toList();
              list.setString("toDoList", json.encode(events));
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
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: ScreenAdapter.width(100),
                                margin: EdgeInsets.only(
                                    right: ScreenAdapter.width(20)),
                                child: Text(
                                  '${item.title}',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis, //'标题'
                                  style: TextStyle(
                                      fontSize: ScreenAdapter.size(20),
                                      color: Color.fromRGBO(16, 16, 16, 1),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    right: ScreenAdapter.width(10)),
                                child: Column(
                                  children: [
                                    Text(
                                      '${item.endDate}まで:',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.size(15),
                                          color: Color.fromRGBO(16, 16, 16, 1)),
                                    ),
                                    Text(
                                      "${item.date}" + "日",
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.size(13),
                                          color: Color.fromRGBO(16, 16, 16, 1)),
                                    ),
                                    Text(
                                      item.time == ""
                                          ? '${item.time}'
                                          : "${_formatDateTime(int.parse('${item.time}'))}",
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.size(13),
                                          color: Color.fromRGBO(16, 16, 16, 1)),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: ScreenAdapter.width(10)),
                        child: TextButton(
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
                          onPressed: () async {
                            //Navigator.pushNamed(context, '/start');
                            Navigator.of(context).push(MaterialPageRoute(
                                //传值
                                builder: (context) => CountDown(
                                      date: int.parse(item.date),
                                      time: int.parse(item.time),
                                      name: "toDoList",
                                      index: index,
                                    )
                                //没传值
                                //builder: (context)=>Detail()
                                ));
                          },
                        ),
                      ),
                    ]))));
  }
}
