//新增代码
import 'package:flutter/material.dart';

import '../../services/ScreenAdapter.dart';
class TodoModel {
  TodoModel({
    required this.id,
    required this.title,
    this.complete = false,
  });

  int id;
  String title;
  bool complete;
}
