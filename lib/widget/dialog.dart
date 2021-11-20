
import 'package:flutter/material.dart';

class DialogEX extends AlertDialog {
  DialogEX({required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.blue, width: 3)),
        );
}

double btnHeight = 60;
double borderWidth = 2;

class DialogContent extends StatefulWidget {
  String title;
  String cancelBtnTitle;
  String okBtnTitle;
  final VoidCallback cancelBtnTap;
  final VoidCallback okBtnTap;
  final editParentText;
  DialogContent(
      {this.title ="",
      this.cancelBtnTitle = "Cancel",
      this.okBtnTitle = "Ok",
      required this.cancelBtnTap,
      required this.okBtnTap,this.editParentText});

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  final textController = TextEditingController();
  void _printLatestValue() {
    print('Second text field: ${textController.text}');
  }

  @override
  void initState() {
    super.initState();
    textController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
          children: [
            Container(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  style: TextStyle(color: Colors.grey),
                )),
          
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                style: TextStyle(color: Colors.black87),
                controller: textController,
                decoration: InputDecoration(
                  labelText: "どうな名前がいいのかな。。。",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    )),
              ),
            ),
            //  Padding(
            //   padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            //   child: TextField(
            //     style: TextStyle(color: Colors.black87),
            //     controller: textController,
            //     decoration: InputDecoration(
            //        labelText: "タイマーだよ",
            //         enabledBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.blue),
            //         ),
            //         focusedBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.blue),
            //         )),
            //   ),
            // ),
            //  Padding(
            //   padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            //   child: TextField(
            //     style: TextStyle(color: Colors.black87),
            //     controller: textController,
            //     decoration: InputDecoration(
            //         enabledBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.blue),
            //         ),
            //         focusedBorder: UnderlineInputBorder(
            //           borderSide: BorderSide(color: Colors.blue),
            //         )),
            //   ),
            // ),
            Spacer(),
            Container(
              height: btnHeight,
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Column(
                children: [
                  // Container(
                  //   // 按钮上面的横线
                  //   width: double.infinity,
                  //   color: Colors.blue,
                  //   height: borderWidth,
                  //   margin: EdgeInsets.only(bottom: 4.0),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          textController.text = "";
                          widget.cancelBtnTap();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.cancelBtnTitle,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            widget.okBtnTap();
                            Navigator.of(context).pop();
                            setState(() {
                            widget.editParentText(textController.text);// 调用父级组件方法
                          });
                          },
                          child: Text(
                            widget.okBtnTitle,
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        );
  }
}
