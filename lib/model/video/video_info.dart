import 'package:book_app/model/video/video.dart';
import 'package:book_app/model/video/video_item.dart';

class VideoInfo{

 Video? video;
 List<VideoItem>? itemList;


 VideoInfo({this.video, this.itemList});

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    Video? video = Video.fromJson(json["video"]);
    List<VideoItem>? itemList = [];
    for (var data in json["itemList"]) {
      itemList.add(VideoItem.fromJson(data));
    }

    return VideoInfo(video: video, itemList: itemList);
  }
}
