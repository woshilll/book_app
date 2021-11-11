import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/video/video_index.dart';
import 'package:book_app/util/rsa_util.dart';

class VideoApi {
  /// 获取影视列表
  static Future<VideoIndex> getIndex() async{
    return VideoIndex.fromJson(await DioManager.instance.get(url: "/app/video", showLoading: true));
  }


}
