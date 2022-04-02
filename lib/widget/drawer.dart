import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:doto_app/model/userData.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:developer' as developer;
import '../pages/tabs/Tabs.dart';

class drawerEX extends StatefulWidget {
  drawerEX({Key? key}) : super(key: key);
  _drawerEX createState() => _drawerEX();
}

class _drawerEX extends State<drawerEX> {
  //ポップアップ
  late UserData userdata;
  late String userName;
  late String userEmail;
  bool login = false;
  late SharedPreferences prefs;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    Future(() async {
      SharedPreferences retult = await SharedPreferences.getInstance();
      if (retult.getString("userdata") != null) {
        login = true;
        userdata = UserData.fromJson(json.decode(retult.getString("userdata")));
      } else {
        userdata = UserData(name: "", email: "", accessToken: "");
      }
      userName = userdata.name == "" ? "" : userdata.name;
      userEmail = userdata.email == "" ? "" : userdata.email;
    });
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
      _connectionStatus = result;
  }

  user() async {
    SharedPreferences retult = await SharedPreferences.getInstance();
    if (retult.getString("userdata") != null) {
      userdata = UserData.fromJson(json.decode(retult.getString("userdata")));
    } else {
      userdata = UserData(name: "", email: "", accessToken: "");
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
      Response response =
          await dio.get("http://www.leishengle.com/api/v1/logout");
      print(response.statusCode);
      if (response.statusCode != null) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('ログアウトしました'),
            duration: Duration(seconds: 1),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('未知なエラーが発生しました'),
          duration: Duration(seconds: 1),
        ));
      }
    } on DioError catch (e) {
      print(e.response.statusCode);
      if (e.response!.statusCode == 302 || e.response!.statusCode == 401) {
        print(e.response);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('既にログアウトしています'),
          duration: Duration(seconds: 1),
        ));
      } else if (e.response!.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('既にログアウトしています'),
          duration: Duration(seconds: 1),
        ));
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('未知なエラーが発生しました'),
          duration: Duration(seconds: 1),
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
                              if (!login) {
                                Navigator.pushNamed(context, '/login');
                              }
                            },
                            child: UserAccountsDrawerHeader(
                                accountName: Text(
                                  !login ? "ユーザ未登録" : "ユーザ名: $userName",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.size(14),
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                ),
                                accountEmail:Text(
                                    !login
                                        ? "メールアドレス未登録"
                                        : "メールアドレス: $userEmail",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.size(14),
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
            ListTile(
            leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.login,
                  color: Colors.white,
                )),
            onTap: () {
              if (_connectionStatus== ConnectivityResult.none) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.deepOrange,
                  content: Text('ネットワークに繋がっていません'),
                  duration: Duration(seconds: 1),
                ));
              } else {
                if (!login) {
                  Navigator.pushNamed(context, '/login');
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.deepOrange,
                  content: Text('既に登録しています。'),
                  duration: Duration(seconds: 1),
                ));
                }
              }
            },
            title: Text(
              "ログイン",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.logout, color: Colors.white)),
              onTap: () {
                if (_connectionStatus== ConnectivityResult.none) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.deepOrange,
                    content: Text('ネットワークに繋がっていません'),
                    duration: Duration(seconds:1),
                  ));
                } else {
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
                                  child: const Text('キャンセル',
                                      style: TextStyle(
                                        color: Colors.green,
                                      )),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await logOut();
                                    setState(() {
                                      login = false;
                                    });
                                    prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.remove("userdata");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Tabs(tabSelected: 0)));
                                  },
                                  child: const Text('確認',
                                      style: TextStyle(
                                        color: Colors.green,
                                      )),
                                ),
                              ],
                            );
                          }));
                }
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
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.help_outline_sharp,
                  color: Colors.white,
                )),
            onTap: () {
              if (_connectionStatus==ConnectivityResult.none) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.deepOrange,
                  content: Text('ネットワークに繋がっていません'),
                  duration: Duration(seconds:1),
                ));
              } else {
                Navigator.pushNamed(context, '/changePassword');
              }
            },
            title: Text(
              "パスワードを変更",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          // ListTile(
          //   leading: CircleAvatar(
          //       backgroundColor: Color(0xFF8ddf67),
          //       child: Icon(Icons.markunread_outlined, color: Colors.white)),
          //   title: Text("連絡先", style: TextStyle(fontWeight: FontWeight.bold)),
          // ),
        ],
      ),
    );
  }
}
