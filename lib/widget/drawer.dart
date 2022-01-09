import 'package:doto_app/model/userData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class drawerEX extends StatelessWidget {
  final UserData userdata;
  drawerEX({required this.userdata});

  late String userName;
  late String userEmail;


  //ポップアップ
  
  @override
  Widget build(BuildContext context) {
    userName = userdata == null ? "" : userdata.name;
    userEmail = userdata == null ? "" : userdata.email;
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
                child:  TextButton(
                   onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                child:UserAccountsDrawerHeader(
                  accountName: Text(userName == "" ? "未登録/サインイン" : "ユーザ名: $userName",
                  style: TextStyle(color: Colors.black87),),
                  accountEmail: Text(userEmail ==""?"メールアドレス":"メールアドレス: $userEmail",
                  style: TextStyle(color: Colors.black87)),
                  currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage("images/user.png")),
                  decoration: BoxDecoration(
                  //   gradient: LinearGradient(
                  //   colors: [Color(0xFFd1e231,), Color(0xFF887c40)],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                    //border:  Border.all(color: Color.fromRGBO(56,179,0,1) ,width: 2),
                     //color:Color.fromRGBO(53,158,5,0.3),
                  ))),
                ),
            ],
          ),
          ListTile(
            leading: CircleAvatar(
                child:
                    Icon(Icons.help_outline_sharp, color: Colors.yellow[50])),
            title: Text("ヘルプ"),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.settings_sharp)),
            title: Text("設定"),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.markunread_outlined)),
            title: Text("連絡先"),
          ),
        ],
      ),
    );
  }
}
