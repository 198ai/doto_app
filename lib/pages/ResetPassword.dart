import 'dart:async';
import 'dart:convert';

import 'package:doto_app/model/userData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ScreenAdapter.dart';
import '../widget/JdText.dart';
import '../widget/JdButton.dart';
import 'package:dio/dio.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({Key? key, this.email = ""}) : super(key: key);

  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool _isShow = false;
  late SharedPreferences prefs;
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

  @override
  void initState() {
    super.initState();
    setState(() {
      mes = "";
      show = false;
      widget.email != "" ? _emailController.text = widget.email : null;
    });
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
                if (await checkLoginFunction()) {
                  Navigator.pushNamed(context, '/');
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
                  errorText: snapshot.data,
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
                  errorText: snapshot.data,
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
                  errorText: snapshot.data,
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
          .post("http://10.0.2.2:8000/api/v1/resetPassword", data: params);
      if (response.statusCode != null) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.data),
            duration: Duration(seconds: 3),
          ));
        }
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text(e.response.data), duration: Duration(seconds: 3)));
      throw (e);
    }
  }
}
