import 'dart:async';
import 'dart:convert';

import 'package:doto_app/model/userData.dart';
import 'package:doto_app/pages/tabs/Tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ScreenAdapter.dart';
import '../widget/JdText.dart';
import '../widget/JdButton.dart';
import 'package:dio/dio.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

class ChangePassword extends StatefulWidget {
  String email;
  ChangePassword({Key? key, this.email = ""}) : super(key: key);

  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool _isShow = false;
  bool _isNewShow = false;
  late SharedPreferences prefs;
  late UserData userdate;
  //用户名输入框的焦点控制
  FocusNode _newPasswordFocusNode = new FocusNode();
  FocusNode _passwordFocusNode = new FocusNode();
  FocusNode _emailFocusNode = new FocusNode();

  //文本输入框控制器
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();

  //抖动动画控制器
  ShakeAnimationController _newPasswordAnimation =
      new ShakeAnimationController();
  ShakeAnimationController _userEmailAnimation = new ShakeAnimationController();
  ShakeAnimationController _userPasswordAnimation =
      new ShakeAnimationController();

  //Stream 更新操作控制器
  StreamController<String> _newPasswordStream = new StreamController();
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
          title: Text("パスワー変更"),
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
          buildUserNewPasswordWidget(),
          Visibility(
              visible: !show,
              child: SizedBox(
                height: 30,
              )),
          Container(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              child: Text("送信する"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green), //背景颜色
              ),
              onPressed: () async {
                if (await checkLoginFunction()) {
                  await changePassword();
                }
                if(successed){
                   Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Tabs(tabSelected: 0)));
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
                  if (checkPassword()) {
                    _newPasswordFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_newPasswordFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  }
                },
                obscureText: !_isShow,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "旧パスワード",
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
                  if (checkemail()) {
                    _emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
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

  StreamBuilder<String> buildUserNewPasswordWidget() {
    return StreamBuilder<String>(
      stream: _newPasswordStream.stream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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
                focusNode: _newPasswordFocusNode,
                controller: _newPasswordController,
                onSubmitted: (String value) {
                  if (checNewPassword()) {
                    _newPasswordFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_newPasswordFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(_newPasswordFocusNode);
                  }
                },
                obscureText: !_isNewShow,
                decoration: InputDecoration(
                  errorText: snapshot.data,
                  labelText: "新パスワード",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffix: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNewShow = !_isNewShow;
                        });
                      },
                      child: Icon(
                        !_isNewShow
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

  Future<bool> checkLoginFunction() async {
    hindKeyBoarder();
    if (checkPassword() & checkemail() & checNewPassword()) {
      return true;
    }
    return false;
  }

  bool checkPassword() {
    String userPassrowe = _passwordController.text;
    if (userPassrowe.length < 6 && userPassrowe.length != 0) {
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

  bool checNewPassword() {
    String userPassrowe = _newPasswordController.text;
    if (userPassrowe.length < 6 && userPassrowe.length != 0) {
      _newPasswordStream.add("パスワードは6文字以上を入力してください");
      _newPasswordAnimation.start();
      return false;
    } else if (userPassrowe.length == 0) {
      _newPasswordStream.add("パスワードを入力してください");
      _newPasswordAnimation.start();
      return false;
    } else {
      _newPasswordStream.add("");
      return true;
    }
  }

  bool checkemail() {
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
        return true;
      } else {
        _userEmailStream.add("正しいメールアドレスを入力してください");
        _userEmailAnimation.start();
        return false;
      }
    }
  }

  String mes = "";
  bool successed = false;
  void hindKeyBoarder() {
    _newPasswordFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _emailFocusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  changePassword() async {
    var params = {
      "email": "${_emailController.text}",
      "password": "${_passwordController.text}",
      "newpassword": "${_newPasswordController.text}"
    };
    try {
      Response response = await Dio()
          .post("http://www.leishengle.com/api/v1/changePassword", data: params);
      if (response.statusCode != null) {
        if (response.statusCode == 201) {
          userdate = UserData.fromJson(response.data);
          var data = userdate.toJson();
          if (userdate.accessToken != "") {
            prefs = await SharedPreferences.getInstance();
            prefs.setString("userdata", json.encode(data));
            successed = true;
            print(prefs.getString("userdata"));
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("パスワードを変更しました"),
            duration: Duration(seconds: 3),
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
