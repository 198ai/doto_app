import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doto_app/model/userData.dart';
import 'package:doto_app/pages/tabs/Tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ScreenAdapter.dart';
import '../widget/JdText.dart';
import '../widget/JdButton.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:shake_animation_widget/shake_animation_widget.dart';

class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({Key? key, this.email = ""}) : super(key: key);

  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _isShow = false;
  late SharedPreferences prefs;
  late UserData userdate;
  //用户名输入框的焦点控制
  FocusNode _codeFocusNode = new FocusNode();
  FocusNode _passwordFocusNode = new FocusNode();
  FocusNode _emailFocusNode = new FocusNode();

  //文本输入框控制器
  TextEditingController _codeController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();

  //抖动动画控制器
  ShakeAnimationController _codeAnimation = new ShakeAnimationController();
  ShakeAnimationController _userEmailAnimation = new ShakeAnimationController();
  ShakeAnimationController _userPasswordAnimation =
      new ShakeAnimationController();

  //Stream 更新操作控制器
  StreamController<String> _codeStream = new StreamController();
  StreamController<String> _userPasswordStream = new StreamController();
  StreamController<String> _userEmailStream = new StreamController();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {
      mes = "";
      show = false;
      widget.email != "" ? _emailController.text = widget.email : null;
    });
  }

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
      if (_connectionStatus == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text('ネットワークに繋がっていません'),
          duration: Duration(seconds: 1),
        ));
      }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hindKeyBoarder();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text("コード認証"),
        ),
        body: buildLoginWidget(),
      ),
    );
  }

  Widget buildLoginWidget() {
    return SingleChildScrollView(
        child: Container(
      margin: EdgeInsets.all(30.0),
      child: Column(
        children: [
          buildUserEmailWidget(),
          SizedBox(
            height: 20,
          ),
          buildUserPasswordWidget(),
          SizedBox(
            height: 20,
          ),
          buildUserNameWidget(),
          Visibility(
              visible: !show,
              child: SizedBox(
                height: 30,
              )),
          Container(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              child: Text("パスワードリセット"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green), //背景颜色
              ),
              onPressed: () async {
                if (_connectionStatus== ConnectivityResult.none) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.deepOrange,
                    content: Text('ネットワークに繋がっていません'),
                    duration: Duration(seconds: 1),
                  ));
                } else {
                  if (await checkLoginFunction()) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Tabs(tabSelected: 0)));
                  }
                }
              },
            ),
          )
        ],
      ),
    ));
  }

  StreamBuilder<String> buildUserPasswordWidget() {
    return StreamBuilder<String>(
      stream: _userPasswordStream.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ShakeAnimationWidget(
            shakeAnimationType: ShakeAnimationType.LeftRightShake,
            isForward: false,
            shakeAnimationController: _userPasswordAnimation,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: Colors.green,
                    ),
              ),
              child: TextField(
                focusNode: _passwordFocusNode,
                controller: _passwordController,
                onSubmitted: (String value) {
                  if (checkCodePassword()) {
                    passwordReset();
                  } else {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  }
                },
                obscureText: !_isShow,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "パスワード",
                  errorText: snapshot.data == "" ? null : snapshot.data,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffix: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isShow = !_isShow;
                        });
                      },
                      child: Icon(
                        !_isShow
                            ? Icons.visibility_off
                            : Icons.remove_red_eye_sharp,
                        color: Colors.grey,
                      )),
                ),
              ),
            ));
      },
    );
  }

  bool show = false;
  StreamBuilder<String> buildUserEmailWidget() {
    return StreamBuilder<String>(
      stream: _userEmailStream.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return ShakeAnimationWidget(
            shakeAnimationType: ShakeAnimationType.LeftRightShake,
            isForward: false,
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
                onSubmitted: (String value) {
                  if (checkCodePassword()) {
                    passwordReset();
                  } else {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  }
                },
                maxLines: 1,
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

  StreamBuilder<String> buildUserNameWidget() {
    return StreamBuilder<String>(
      stream: _codeStream.stream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return ShakeAnimationWidget(
            shakeAnimationType: ShakeAnimationType.LeftRightShake,
            isForward: false,
            shakeAnimationController: _codeAnimation,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: Colors.green,
                    ),
              ),
              child: TextField(
                focusNode: _codeFocusNode,
                controller: _codeController,
                onSubmitted: (String value) {
                  if (checkUserName()) {
                    _codeFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(_codeFocusNode);
                  }
                },
                decoration: InputDecoration(
                  errorText: snapshot.data == "" ? null : snapshot.data,
                  labelText: "認証コード",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ));
      },
    );
  }

  Future<bool> checkLoginFunction() async {
    hindKeyBoarder();
    if (checkUserName() & checkCodePassword() & checkemailPassword()) {
      await passwordReset();
    }
    if (successed) {
      return true;
    }
    return false;
  }

  bool checkUserName() {
    String userName = _codeController.text;
    if (userName.length == 0) {
      _codeStream.add("認証コードを入力してください");
      _codeAnimation.start();
      return false;
    } else if (userName.length == 6) {
      _codeStream.add("");
      return true;
    } else {
      _codeStream.add("6桁数の認証コードを入力してください");
      _codeAnimation.start();
      return false;
    }
  }

  bool checkCodePassword() {
    String userPassrowe = _passwordController.text;
    if (userPassrowe.length < 5 && userPassrowe.length != 0) {
      _userPasswordStream.add("パスワードは6文字以上を入力してください");
      _userPasswordAnimation.start();
      return false;
    } else if (userPassrowe.length == 0) {
      _userPasswordStream.add("パスワードを入力してください");
      _userPasswordAnimation.start();
      return false;
    } else {
      _userPasswordStream.add("");
      return true;
    }
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

  String mes = "";
  bool successed = false;
  void hindKeyBoarder() {
    _codeFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _emailFocusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  passwordReset() async {
    var params = {
      "token": "${_codeController.text}",
      "email": "${_emailController.text}",
      "password": "${_passwordController.text}"
    };
    try {
      Response response = await Dio()
          .post("http://www.leishengle.com/api/v1/resetPassword", data: params);
      if (response.statusCode != null) {
        userdate = UserData.fromJson(response.data);
        var data = userdate.toJson();
        if (userdate.accessToken != "") {
          prefs = await SharedPreferences.getInstance();
          prefs.setString("userdata", json.encode(data));
          successed = true;
          print(prefs.getString("userdata"));
        }
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("パスワードをリセットしました"),
            duration: Duration(seconds: 1),
          ));
        }
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text(e.response.data),
          duration: Duration(seconds: 3)));
      throw (e);
    }
  }
}
