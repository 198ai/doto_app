//新增代码
import 'package:flutter/material.dart';

import '../../services/ScreenAdapter.dart';

class TodoModel {
  int id;
  String title;
  int complete;
  String time;
  String date;
  String endDate;

  TodoModel(
      {required this.id,
      required this.title,
      required this.complete,
      required this.time,
      required this.date,
      required this.endDate});

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
      id: json['id'],
      title: json['title'],
      complete: json['complete'],
      time: json['time'],
      date: json['date'],
      endDate:json['endDate']);

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'title': this.title,
        'complete': this.complete,
        'time': this.time,
        'date': this.date,
        'endDate':this.endDate,
      };
}
