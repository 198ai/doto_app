class getQuestionnaire {
  String? id;
  String? important;
  String? sts;
  String? subject;
  String? entryname;
  String? entrydate;
  String? progress;
  String? perioddays;
  String? period;
  String? cretime;
  String? unread;
  String? prstatus;

  getQuestionnaire(
      {this.id,
      this.important,
      this.sts,
      this.subject,
      this.entryname,
      this.entrydate,
      this.progress,
      this.perioddays,
      this.period,
      this.cretime,
      this.unread,
      this.prstatus});

  getQuestionnaire.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    important = json['important'];
    sts = json['sts'];
    subject = json['subject'];
    entryname = json['entryname'];
    entrydate = json['entrydate'];
    progress = json['progress'];
    perioddays = json['perioddays'];
    period = json['period'];
    cretime = json['cretime'];
    unread = json['unread'];
    prstatus = json['prstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['important'] = this.important;
    data['sts'] = this.sts;
    data['subject'] = this.subject;
    data['entryname'] = this.entryname;
    data['entrydate'] = this.entrydate;
    data['progress'] = this.progress;
    data['perioddays'] = this.perioddays;
    data['period'] = this.period;
    data['cretime'] = this.cretime;
    data['unread'] = this.unread;
    data['prstatus'] = this.prstatus;
    return data;
  }
}