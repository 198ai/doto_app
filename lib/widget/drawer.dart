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
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: UserAccountsDrawerHeader(
                    accountName: Text("未登録/サインイン"),
                    accountEmail: Text("メールアドレス"),
                    currentAccountPicture: CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://www.itying.com/images/flutter/3.png")),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: NetworkImage(
                          "https://www.itying.com/images/flutter/2.png"),
                      fit: BoxFit.cover,
                    )),
                  ),
                ),
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
