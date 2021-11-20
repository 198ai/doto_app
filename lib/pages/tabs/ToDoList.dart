import 'dart:async';
import 'package:doto_app/widget/dialog.dart';
import 'package:doto_app/widget/drawer.dart';
import 'package:flutter/material.dart';
import '../../model/tasklist.dart';
import '../../services/ScreenAdapter.dart';
//ローカルストレージ保存するため
import 'package:shared_preferences/shared_preferences.dart';

class ToDoListPage extends StatefulWidget {
  ToDoListPage({Key? key}) : super(key: key);

  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<TodoModel> todos = [];
  List<String> storge = [];
  int id = 0;
  final textController = TextEditingController();
  void _printLatestValue() {
    print('Second text field: ${textController.text}');
  }

  @override
  void initState() {
    super.initState();
    //追加ポップアップに書いた内容を記録
    textController.addListener(_printLatestValue);
    //ローカルストレージから、値をLISTに渡す、初期化する
    Future(() async {
      SharedPreferences retult = await SharedPreferences.getInstance();
       retult.getStringList("todos") ==null?storge =[]:storge =retult.getStringList("todos");
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
        //TODOLISTの初期化
        _listView();
      }
    });
  }

//違う画面へ行くとき、今の画面を破棄して、追加TEXT記録も破棄
  @override
  void dispose() {
    textController.dispose();
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

//画面のHTML
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      return Container(
                        margin: EdgeInsets.only(
                            top: ScreenAdapter.height(150),
                            right: ScreenAdapter.width(6),
                            left: ScreenAdapter.width(6),
                            bottom: ScreenAdapter.height(120)),
                        height: ScreenAdapter.height(499),
                        width: ScreenAdapter.width(296),
                        alignment: Alignment.bottomCenter,
                        child: DialogEX(
                          contentWidget: DialogContent(
                              //title: "今日も新たな挑戦を始めるね！＾-＾素晴らしい！",
                              okBtnTap: () {
                                print(
                                  "入力した名前は:",
                                );
                              },
                              okBtnTitle: "チャレンジ始める",
                              cancelBtnTitle: "今日はサボる",
                              cancelBtnTap: () {},
                              editParentText: (taskName) =>
                                  _editParentText(taskName)),
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

  Card _normalCard(item, index) {
    return Card(
      elevation: 15.0, //设置阴影
      margin: EdgeInsets.only(
          top: ScreenAdapter.height(25),
          left: ScreenAdapter.width(21),
          right: ScreenAdapter.width(21)),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14.0))), //设置圆角
      child: Padding(
        padding: EdgeInsets.all(20),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '${item.title}', //'标题'
            style: TextStyle(
                fontSize: ScreenAdapter.size(28),
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

          // InkWell(
          //     onTap: () {
          //       deleteTodo(index);
          //     },
          //     child: Icon(Icons.close))
        ]),
      ),
    );
  }
}
