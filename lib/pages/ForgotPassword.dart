import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:doto_app/model/tasklist.dart';
import 'package:doto_app/pages/ResetPassword.dart';
import 'package:doto_app/services/ScreenAdapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:developer' as developer;
import 'package:shake_animation_widget/shake_animation_widget.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);

  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //用户名输入框的焦点控制
  FocusNode _emailFocusNode = new FocusNode();
  void hindKeyBoarder() {
    //输入框失去焦点
    _emailFocusNode.unfocus();
  }

  //文本输入框控制器
  TextEditingController _emailController = new TextEditingController();

  //抖动动画控制器
  ShakeAnimationController _userEmailAnimation = new ShakeAnimationController();

  //Stream 更新操作控制器
  StreamController<String> _userEmailStream = new StreamController();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    //手势识别点击空白隐藏键盘
    return GestureDetector(
      onTap: () {
        hindKeyBoarder();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("パスワードリセット"),
        ),
        //登录页面的主体
        body: buildLoginWidget(),
      ),
    );
  }

  bool checked = false;
  //登录页面的主体
  Widget buildLoginWidget() {
    return SingleChildScrollView(
        child: Container(
      margin: EdgeInsets.all(30.0),
      //线性布局
      child: Column(
        children: [
          buildUserEmailWidget(),
          SizedBox(
            height: 10,
          ),
          TextButton(
            style: ButtonStyle(
              //定义文本的样式 这里设置的颜色是不起作用的
              textStyle: MaterialStateProperty.all(
                  TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
            child: Text("認証コードを持っている"),
            onPressed: () async {
              //Navigator.pushNamed(context, '/resetPassword');
              Navigator.of(context).push(MaterialPageRoute(
                  //传值
                  builder: (context) => ResetPassword(
                        email: _emailController.text,
                      )));
            },
          ),
          //登录按钮
          Container(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              child: Text("認証コード送信する"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green), //背景颜色
              ),
              onPressed: () async {
                if (_connectionStatus == ConnectivityResult.none) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.deepOrange,
                    content: Text('ネットワークに繋がっていません'),
                    duration: Duration(seconds: 1),
                  ));
                } else {
                  if (checkemailPassword()) {
                    await forgotPassword();
                  }
                  if (checked) {
                    Navigator.of(context).push(MaterialPageRoute(
                        //传值
                        builder: (context) => ResetPassword(
                              email: _emailController.text,
                            )));
                  }
                }
              },
            ),
          )
        ],
      ),
    ));
  }

  bool checkemailPassword() {
    String userEmail = _emailController.text;
    if (userEmail.length == 0) {
      _userEmailStream.add("メールアドレスを入力してください");
      _userEmailAnimation.start();
      return false;
    } else {
      String regexEmail =
          "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";
      if (RegExp(regexEmail).hasMatch(_emailController.text)) {
        _userEmailStream.add("");
      } else {
        _userEmailStream.add("正しいメールアドレスを入力してください");
        _userEmailAnimation.start();
      }
      return true;
    }
  }

  StreamBuilder<String> buildUserEmailWidget() {
    return StreamBuilder<String>(
      stream: _userEmailStream.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ShakeAnimationWidget(
            //微左右的抖动
            shakeAnimationType: ShakeAnimationType.LeftRightShake,
            //设置不开启抖动
            isForward: false,
            //抖动控制器
            shakeAnimationController: _userEmailAnimation,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: Colors.green,
                    ),
              ),
              child: TextField(
                focusNode: _emailFocusNode,
                controller: _emailController,
                onSubmitted: (String value) {},
                //最大可输入1行
                maxLines: 1,
                //边框样式设置
                decoration: InputDecoration(
                  labelText: "メールアドレス",
                  errorText: snapshot.data == "" ? null : snapshot.data,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ));
      },
    );
  }

  forgotPassword() async {
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var params = {
      "email": "${_emailController.text}",
    };
    try {
      Response response = await dio.post(
          "http://www.leishengle.com/api/v1/forgotpassword",
          data: params);

      if (response.statusCode != null) {
        if (response.statusCode == 201) {
          //成功改成true
          checked = true;
          print(response.data);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.data),
            duration: Duration(seconds: 1),
          ));
        }
      }
    } on DioError catch (e) {
      print(e.request);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text(e.response.data),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
