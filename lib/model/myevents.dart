class MyEvents {
  final String eventTitle;
  final String eventDescp;
  final String alarm;
  MyEvents(
      {required this.eventTitle,
      required this.eventDescp,
      required this.alarm});

  @override
  String toString() => eventTitle;
  factory MyEvents.fromJson(Map<String, dynamic> json) => MyEvents(
        eventTitle: json["eventTitle"],
        eventDescp: json["eventDescp"],
        alarm: json["alarm"],
      );

  Map<String, dynamic> toJson() => {
        "eventTitle": eventTitle,
        "eventDescp": eventDescp,
        "alarm": alarm,
      };
}