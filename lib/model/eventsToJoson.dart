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

// class Events {
//   String? eventTitle;
//   String? eventDescp;
//   String? alarm;
//   int? alarmId;

//   Events({this.eventTitle, this.eventDescp, this.alarm, this.alarmId});

//   Events.fromJson(Map<String, dynamic> json) {
//     eventTitle = json['eventTitle'];
//     eventDescp = json['eventDescp'];
//     alarm = json['alarm'];
//     alarmId = json['alarmId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['eventTitle'] = this.eventTitle;
//     data['eventDescp'] = this.eventDescp;
//     data['alarm'] = this.alarm;
//     data['alarmId'] = this.alarmId;
//     return data;
//   }
// }