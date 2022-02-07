class MyEvents {
  final String eventTitle;
  final String eventDescp;
  final String alarm;
  final int alarmId;
  late int status;
  late String updatetime;
  MyEvents(
      {required this.eventTitle,
      required this.eventDescp,
      required this.alarm,
      required this.alarmId,
      required this.status,
      required this.updatetime});

  @override
  String toString() => eventTitle;
  factory MyEvents.fromJson(Map<String, dynamic> json) => MyEvents(
      eventTitle: json["eventTitle"],
      eventDescp: json["eventDescp"],
      alarm: json["alarm"],
      alarmId: json["alarmId"],
      status: json["status"],
      updatetime: json["updatetime"],);

  Map<String, dynamic> toJson() => {
        "eventTitle": eventTitle,
        "eventDescp": eventDescp,
        "alarm": alarm,
        "alarmId": alarmId,
        "status": status,
        "updatetime":updatetime
      };
}
