import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/ScreenAdapter.dart';

class JdText extends StatefulWidget {
  final String text;
  final bool password;
  var onChanged;
  var myController;
  
  JdText(
      {Key? key,
      this.text = "输入内容",
      this.password = false,
      this.onChanged = null,
      this.myController =null,})
      : super(key: key);

  @override
  _JdTextState createState() => _JdTextState();
}

class _JdTextState extends State<JdText> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: this.widget.myController,
        obscureText: this.widget.password,
        decoration: InputDecoration(
            hintText: this.widget.text,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none)),
        onChanged: this.widget.onChanged,
      ),
      height: 68,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
    );
  }
}
