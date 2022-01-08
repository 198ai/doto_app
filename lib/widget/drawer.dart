import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class drawerEX extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                alignment:Alignment.center,
                height: 200,
                child:Container(
                  padding:EdgeInsets.only(left:30) ,
                child: TextButton(
                  child:Text("未登録/サインイン"),
                  style:  ButtonStyle(
                  //定义文本的样式 这里设置的颜色是不起作用的
                  textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 28, color: Colors.red)),
                      foregroundColor: MaterialStateProperty.all(Colors.deepPurple),), 
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                )
               
              ),

              // Expanded(
              //   child: UserAccountsDrawerHeader(
              //     accountName: Text("未登録/サインイン"),
              //     accountEmail: Text("メールアドレス"),
              //     currentAccountPicture: CircleAvatar(
              //       backgroundImage: NetworkImage("https://www.itying.com/images/flutter/3.png")
              //     ),
              //     decoration:BoxDecoration(
              //         image: DecorationImage(
              //           image: NetworkImage("https://www.itying.com/images/flutter/2.png"),
              //           fit:BoxFit.cover,
              //         )
              //     ),
              //   ),
              // ),
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
