import 'package:doto_app/model/myevents.dart';

class EventsToJson {
  String? calendar;
  List<MyEvents>? events;

  EventsToJson({this.calendar, this.events});

  EventsToJson.fromJson(Map<String, dynamic> json) {
    calendar = json['calendar'];
    if (json['events'] != null) {
      events = <MyEvents>[];
      json['events'].forEach((v) {
        events!.add(new MyEvents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['calendar'] = this.calendar;
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
