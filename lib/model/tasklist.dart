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
  String created_at;
  String updated_at;
  TodoModel(
      {required this.id,
      required this.title,
      required this.complete,
      required this.time,
      required this.date,
      required this.endDate,
      required this.created_at,
      required this.updated_at,
      });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
      id: json['id'],
      title: json['title'],
      complete: json['complete'],
      time: json['time'],
      date: json['date'],
      endDate: json['endDate'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': this.id,
        'title': this.title,
        'complete': this.complete,
        'time': this.time,
        'date': this.date,
        'endDate': this.endDate,
        'created_at': this.created_at,
        'updated_at': this.updated_at,
      };
}
