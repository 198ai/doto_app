import 'dart:async';
import 'dart:io';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class Alarm {
  late Timer _timer;

  // アラームを開始する
  //https://lab.astamuse.co.jp/entry/flutter-timer-app#%E3%82%A2%E3%83%A9%E3%83%BC%E3%83%A0%E3%82%92%E9%B3%B4%E3%82%89%E3%81%99%E6%96%B9%E6%B3%95

  /// アラームをスタートする
  void start() {
    FlutterRingtonePlayer.playAlarm(looping:false,asAlarm:false);
    // アラーム音を止めるまで鳴らし続ける。Androidの場合はサイレントモードでも音が出る
    if (Platform.isIOS) {
      _timer = Timer.periodic(
        Duration(seconds: 4),
        (Timer timer) => {FlutterRingtonePlayer.playAlarm()},
      );
    }
  }
  void oneTime(){
    FlutterRingtonePlayer.playNotification();
  }

  void start2(){
    FlutterRingtonePlayer.playRingtone(); 
    // 着信音を止めるまで鳴らし続ける。Androidでもサイレントモード時は音が出ない
  }
  /// アラームをストップする
  void stop() {
    if (Platform.isAndroid) {
      FlutterRingtonePlayer.stop();
    } else if (Platform.isIOS) {
      if (_timer != null && _timer.isActive) _timer.cancel();
    }
  }
}