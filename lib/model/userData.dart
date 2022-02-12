class UserData {
  UserData({
    required this.name,
    required this.email,
    required this.accessToken,
  });
  late final String name;
  late final String email;
  late final String accessToken;
  
  UserData.fromJson(Map<String, dynamic> json){
    name = json['name'];
    email = json['email'];
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['access_token'] = accessToken;
    return _data;
  }
}