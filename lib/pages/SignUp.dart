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

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isShow = false;
  late SharedPreferences prefs;
  //用户名输入框的焦点控制
  FocusNode _userNameFocusNode = new FocusNode();
  FocusNode _passwordFocusNode = new FocusNode();
  FocusNode _emailFocusNode = new FocusNode();

  //文本输入框控制器
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();

  //抖动动画控制器
  ShakeAnimationController _userNameAnimation = new ShakeAnimationController();
  ShakeAnimationController _userEmailAnimation = new ShakeAnimationController();
  ShakeAnimationController _userPasswordAnimation =
      new ShakeAnimationController();

  //Stream 更新操作控制器
  StreamController<String> _userNameStream = new StreamController();
  StreamController<String> _userPasswordStream = new StreamController();
  StreamController<String> _userEmailStream = new StreamController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      mes = "";
      show = false;
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
          title: Text("アカウント新規"),
        ),
        //登录页面的主体
        body: buildLoginWidget(),
      ),
    );
  }

//登录页面的主体
  Widget buildLoginWidget() {
    return SingleChildScrollView(
        child: Container(
      margin: EdgeInsets.all(30.0),
      //线性布局
      child: Column(
        children: [
          //用户名输入框
          buildUserNameWidget(),
          SizedBox(
            height: 20,
          ),
          //用户密码输入框
          buildUserEmailWidget(),
          SizedBox(
            height: 20,
          ),
          buildUserPasswordWidget(),
          Visibility(
              visible: !show,
              child: SizedBox(
                height: 40,
              )),
          Visibility(
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                mes,
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ),
            visible: show,
          ),
          //登录按钮
          Container(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              child: Text("新規登録"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green), //背景颜色
              ),
              onPressed: () async {
               await checkLoginFunction();
                if (successed) {
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
            //微左右的抖动
            shakeAnimationType: ShakeAnimationType.LeftRightShake,
            //设置不开启抖动
            isForward: false,
            //抖动控制器
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
                onSubmitted: (String value) async {
                  if (checkUserPassword()) {
                    checkLoginFunction();
                  } else {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  }
                },
                //隐藏输入的文本
                obscureText: !_isShow,
                //最大可输入1行
                maxLines: 1,
                //边框样式设置

                decoration: InputDecoration(
                  labelText: "パスワード",
                  errorText: snapshot.data==""?null:snapshot.data,
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
                onSubmitted: (String value) {
                  if (checkEmail()) {
                    _emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  }
                },

                //最大可输入1行
                maxLines: 1,
                //边框样式设置
                decoration: InputDecoration(
                  labelText: "メールアドレス",
                  errorText: snapshot.data==""?null:snapshot.data,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ));
      },
    );
  }

  ///用户名输入框 Stream 局部更新 error提示
  ///     ShakeAnimationWidget 抖动动画
  ///
  StreamBuilder<String> buildUserNameWidget() {
    return StreamBuilder<String>(
      stream: _userNameStream.stream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return ShakeAnimationWidget(
            //微左右的抖动
            shakeAnimationType: ShakeAnimationType.LeftRightShake,
            //设置不开启抖动
            isForward: false,
            //抖动控制器
            shakeAnimationController: _userNameAnimation,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData().colorScheme.copyWith(
                      primary: Colors.green,
                    ),
              ),
              child: TextField(
                //焦点控制
                focusNode: _userNameFocusNode,
                //文本控制器
                controller: _userNameController,
                //键盘回车键点击回调
                onSubmitted: (String value) {
                  //点击校验，如果有内容输入 输入焦点跳入下一个输入框
                  if (checkUserName()) {
                    _userNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(_userNameFocusNode);
                  }
                },
                //边框样式设置
                decoration: InputDecoration(
                  //红色的错误提示文本
                  errorText: snapshot.data==""?null:snapshot.data,
                  labelText: "ユーザ名",
                  //设置上下左右 都有边框
                  //设置四个角的弧度
                  border: OutlineInputBorder(
                    //设置边框四个角的弧度
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
    print(checkUserName());
    print(checkUserPassword());
    print(checkEmail());
    if (checkUserName() & checkUserPassword() & checkEmail()) {
      await loginFunction();
      return true;
    }
    if (successed) {
      return true;
    }
    return false;
  }

  bool checkUserName() {
    //获取输入框中的输入文本
    String userName = _userNameController.text;
    if (userName.length == 0) {
      //Stream 事件流更新提示文案
      _userNameStream.add("ユーザ名を入力してください");
      //抖动动画开启
      _userNameAnimation.start();
      return false;
    } else {
      //清除错误提示
      _userNameStream.add("");
      return true;
    }
  }

  bool checkUserPassword() {
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

  bool checkEmail() {
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
    //输入框失去焦点
    _userNameFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _emailFocusNode.unfocus();
    //隐藏键盘
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  loginFunction() async {
    var params = {
      "name": "${_userNameController.text}",
      "email": "${_emailController.text}",
      "password": "${_passwordController.text}"
    };
    print(params);
    try {
      Response response = await Dio()
          .post("http://www.leishengle.com/api/v1/signup", data: params);
      print(response.statusCode);
      if (response.statusCode != null) {
        if (response.statusCode == 201) {
          UserData userdate = UserData.fromJson(response.data);
          var data = userdate.toJson();
          if (userdate.accessToken != "") {
            prefs = await SharedPreferences.getInstance();
            prefs.setString("userdata", json.encode(data));
            successed = true;
            print(prefs.getString("userdata"));
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("アカウント新規しました"),
            duration: Duration(seconds: 3),
          ));
        }
      }
    } on DioError catch (e) {
      if (e.response!.statusCode == 401) {
        setState(() {
          show = true;
          mes = "ユーザ名かメールアドレスは既に使われています";
        });
      } else if (e.response!.statusCode == 500) {
        setState(() {
          show = true;
          mes = 'サーバーと繋がっていません';
        });
      } else {
        setState(() {
          show = true;
          mes = '未知なエラーが発生しました';
        });
      }
      throw (e);
    }
  }
}
