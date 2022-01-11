/**
 * {
 * 1.id
 * 3.alarmTitle
 * 4.
 * }   
 * [{"alarmId":1,"alarmTitle":"会議","alarmSubTitle":"会議時間まとめ","alarmDate":"2021-12-31 10:31:00:00","status":"0"}]
 */
class MyAlarm {
  int alarmId;
  String alarmTitle;
  String alarmSubTitle;
  String alarmDate;
  int status;

  MyAlarm(
      {required this.alarmId,
      required this.alarmTitle,
      required this.alarmSubTitle,
      required this.alarmDate,
      required this.status});
  @override
  factory MyAlarm.fromJson(Map<String, dynamic> json) => MyAlarm(
      alarmId: json['alarmId'],
      alarmTitle: json['alarmTitle'],
      alarmSubTitle: json['alarmSubTitle'],
      alarmDate: json['alarmDate'],
      status: json['status']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alarmId'] = this.alarmId;
    data['alarmTitle'] = this.alarmTitle;
    data['alarmSubTitle'] = this.alarmSubTitle;
    data['alarmDate'] = this.alarmDate;
    data['status'] = this.status;
    return data;
  }
}
