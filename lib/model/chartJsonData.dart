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
  late String date;
  late List<Contents> contents;
  
  ChartJsonData.fromJson(Map<String, dynamic> json){
    date = json['date'];
    contents = List.from(json['contents']).map((e)=>Contents.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['date'] = date;
    data['contents'] = contents.map((e)=>e.toJson()).toList();
    return data;
  }
}

class Contents {
  Contents({
    required this.events,
    required this.times,
  });
  late String events;
  late int times;
  Contents.fromJson(Map<String, dynamic> json){
    events = json['events'];
    times = int.parse(json['times']);
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['events'] = events;
    data['times'] = times;
    return data;
  }
}