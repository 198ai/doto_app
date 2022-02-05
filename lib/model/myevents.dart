class MyEvents {
  final String eventTitle;
  final String eventDescp;
  final String alarm;
  final int id;
  MyEvents(
      {required this.eventTitle,
      required this.eventDescp,
      required this.alarm,
      required this.id});

  @override
  String toString() => eventTitle;
  factory MyEvents.fromJson(Map<String, dynamic> json) => MyEvents(
        eventTitle: json["eventTitle"],
        eventDescp: json["eventDescp"],
        alarm: json["alarm"],
        id: json["id"]
      );

  Map<String, dynamic> toJson() => {
        "eventTitle": eventTitle,
        "eventDescp": eventDescp,
        "alarm": alarm,
        "id":id
      };
}
