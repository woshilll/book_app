import 'package:book_app/model/video/play_info.dart';
import 'package:book_app/model/video/video_base.dart';

class AliyunPlayInfo {
  VideoBase? videoBase;
  List<PlayInfo>? playInfoList;

  AliyunPlayInfo({this.videoBase, this.playInfoList});

  factory AliyunPlayInfo.fromJson(Map<String, dynamic> json) {
    VideoBase? videoBase = VideoBase.fromJson(json["videoBase"]);
    List<PlayInfo>? playInfoList = [];
    for (var data in json["playInfoList"]) {
      playInfoList.add(PlayInfo.fromJson(data));
    }

    return AliyunPlayInfo(videoBase: videoBase, playInfoList: playInfoList);
  }

  @override
  String toString() {
    return 'AliyunPlayInfo{videoBase: $videoBase, playInfoList: $playInfoList}';
  }
}
