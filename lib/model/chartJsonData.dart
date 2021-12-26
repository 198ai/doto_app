// class ChartJsonChartJsonData {
//   ChartJsonChartJsonData({
//     required this.data,
//   });
//   late final ChartJsonData data;
  
//   ChartJsonChartJsonData.fromJson(Map<String, dynamic> json){
//     data = ChartJsonData.fromJson(json['data']);
//   }

//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['data'] = data.toJson();
//     return _data;
//   }
// }

class ChartJsonData {
  ChartJsonData({
    required this.date,
    required this.contents,
  });
  late final String date;
  late final List<Contents> contents;
  
  ChartJsonData.fromJson(Map<String, dynamic> json){
    date = json['date'];
    contents = List.from(json['contents']).map((e)=>Contents.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['date'] = date;
    _data['contents'] = contents.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Contents {
  Contents({
    required this.events,
    required this.times,
    required this.percent,
  });
  late final String events;
  late final int times;
  late  int percent;
  Contents.fromJson(Map<String, dynamic> json){
    events = json['events'];
    times = json['times'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['events'] = events;
    _data['times'] = times;
    return _data;
  }
}