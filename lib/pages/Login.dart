import 'package:flutter/material.dart';
import '../services/ScreenAdapter.dart';
import '../widget/JdText.dart';
import '../widget/JdButton.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';
  final myController = TextEditingController();
  final myController2 = TextEditingController();
  login() async {
    Dio dio = Dio();
    try {
      var response = await dio.post("https://jd.itying.com/api/doLogin",
          data: {"username": 18546952856, "password": 12345});
      
      if (response.statusCode == 200) {
        print("登録成功");
        print(response);
      }
    } catch (e) {
      print(e);
    }
    print("$username$password");
  }

  void _usernameValue() {
    myController.text == null ? username = " " : username = myController.text;
    print('username: ${myController.text}');
  }

  void _passwordValue() {
    myController2.text == null ? password = " " : password = myController2.text;
    print('password: ${myController2.text}');
  }

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    myController.addListener(_usernameValue);

    myController2.addListener(_passwordValue);
  }

  @override
  void dispose() {
    myController.dispose();
    myController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("ログイン"),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Center(child: Container()),
            SizedBox(height: 30),
            JdText(
              myController: myController,
              text: " ユーザー名",
            ),
            SizedBox(height: 10),
            JdText(
              myController: myController2,
              text: "パスワード",
              password: true,
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(20),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'パスワードを忘れた場合',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/registerFirst');
                      },
                      child: Text(
                        '新しいアカントを作ります',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            JdButton(
              text: "登録",
              color: Colors.blue,
              height: 74,
              cb: () {
                username != "" && password != ""
                    ? login()
                    : username == ""
                        ? print("ユーザー名を入力してください")
                        : print("パスワードを入力してください");
              },
            )
          ],
        ),
      ),
    );
  }
}
