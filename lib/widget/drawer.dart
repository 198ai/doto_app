import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:doto_app/model/userData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class drawerEX extends StatefulWidget {
  drawerEX({Key? key}) : super(key: key);
  _drawerEX createState() => _drawerEX();
}

class _drawerEX extends State<drawerEX> {
  //ポップアップ
  late UserData userdata;
  late String userName;
  late String userEmail;
  late SharedPreferences prefs;
  @override
  void initState() {
    Future(() async {
      SharedPreferences retult = await SharedPreferences.getInstance();
      if (retult.getString("userdata") != "") {
        userdata = UserData.fromJson(json.decode(retult.getString("userdata")));
      }else {
      userdata = UserData(name:"", email: "", accessToken: "");
      }
      userName = userdata.name == "" ? "" : userdata.name;
      userEmail = userdata.email == "" ? "" : userdata.email;
    });
  }

  user() async {
    SharedPreferences retult = await SharedPreferences.getInstance();
    if (retult.getString("userdata") != null) {
      userdata = UserData.fromJson(json.decode(retult.getString("userdata")));
    } else {
      userdata = UserData(name:"", email: "", accessToken: "");
    }
    userName = userdata.name == "" ? "" : userdata.name;
    userEmail = userdata.email == "" ? "" : userdata.email;
  }

  logOut() async {
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    print("Bearer ${userdata.accessToken}");

    ///请求header的配置
    dio.options.headers['authorization'] = "Bearer ${userdata.accessToken}";
    try {
      Response response = await dio.get("http://10.0.2.2:8000/api/v1/logout");
      print(response.statusCode);
      if (response.statusCode != null) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('ログアウトしました'),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('未知なエラーが発生しました'),
          duration: Duration(seconds: 3),
        ));
      }
    } on DioError catch (e) {
      print(e.response.statusCode);
      if (e.response!.statusCode == 302 || e.response!.statusCode == 401) {
        print(e.response);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('既にログアウトしています'),
          duration: Duration(seconds: 3),
        ));
      } else if (e.response!.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('既にログアウトしています'),
          duration: Duration(seconds: 3),
        ));
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('未知なエラーが発生しました'),
          duration: Duration(seconds: 3),
        ));
        throw (e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Container(
              //     alignment: Alignment.center,
              //     height: 200,
              //     child: Container(
              //       padding: EdgeInsets.only(left: 13),
              //       child: TextButton(
              //         child: Text(userName==""?"未登録/サインイン":userName),
              //         style: ButtonStyle(
              //           //定义文本的样式 这里设置的颜色是不起作用的
              //           textStyle: MaterialStateProperty.all(
              //               TextStyle(fontSize: 28, color: Colors.red)),
              //           foregroundColor:
              //               MaterialStateProperty.all(Colors.black45),
              //         ),
              //         onPressed: () {
              //           Navigator.pushNamed(context, '/login');
              //         },
              //       ),
              //     )),

              Expanded(
                  child: FutureBuilder(
                      future: user(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return TextButton(
                            onPressed: () {
                              //Navigator.pushNamed(context, '/login');
                            },
                            child: UserAccountsDrawerHeader(
                                accountName: Text(
                                  userName == "" ? "ユーザ未登録" : "ユーザ名: $userName",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                                accountEmail: Text(
                                    userEmail == ""
                                        ? "メールアドレス未登録"
                                        : "メールアドレス: $userEmail",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold)),
                                currentAccountPicture: CircleAvatar(
                                    backgroundImage:
                                        AssetImage("images/user.png")),
                                decoration: BoxDecoration(
                                    //   gradient: LinearGradient(
                                    //   colors: [Color(0xFFd1e231,), Color(0xFF887c40)],
                                    //   begin: Alignment.topCenter,
                                    //   end: Alignment.bottomCenter,
                                    // ),
                                    //border:  Border.all(color: Color.fromRGBO(56,179,0,1) ,width: 2),
                                    //color:Color.fromRGBO(53,158,5,0.3),
                                    )));
                      })),
            ],
          ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          ListTile(
            leading: CircleAvatar(
                backgroundColor: Color(0xFF8ddf67),
                child: Icon(
                  Icons.help_outline_sharp,
                  color: Colors.white,
                )),
            title: Text(
              "ヘルプ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          ListTile(
              leading: CircleAvatar(
                  backgroundColor: Color(0xFF8ddf67),
                  child: Icon(Icons.settings_sharp, color: Colors.white)),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                            //在这里为了区分，在构建builder的时候将setState方法命名为了setBottomSheetState。
                            builder: (context1, showDialogState) {
                          return AlertDialog(
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('ログアウトしますか？'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await logOut();
                                  setState(() {
                                    userName = "";
                                    userEmail = "";
                                  });
                                  prefs = await SharedPreferences.getInstance();
                                  prefs.remove("userdata");
                                  Navigator.pop(context);
                                },
                                child: const Text('確認'),
                              ),
                            ],
                          );
                        }));
              },
              title: Text(
                "ログアウト",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          ListTile(
            leading: CircleAvatar(
                backgroundColor: Color(0xFF8ddf67),
                child: Icon(Icons.markunread_outlined, color: Colors.white)),
            title: Text("連絡先", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
