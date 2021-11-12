import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/video/aliyun_play_info.dart';
import 'package:book_app/model/video/video_index.dart';
import 'package:book_app/model/video/video_info.dart';
import 'package:book_app/util/rsa_util.dart';

class VideoApi {
  /// 获取影视列表
  static Future<VideoIndex> getIndex() async{
    return VideoIndex.fromJson(await DioManager.instance.get(url: "/app/video", showLoading: true));
  }

  /// 获取影视详情
  static Future<VideoInfo> getInfo(id) async{
    return VideoInfo.fromJson(await DioManager.instance.get(url: "/app/video/info/$id", showLoading: true));
  }


  /// 获取播放详情
  static Future<AliyunPlayInfo> getPlayInfo(vid, itemId) async{
    return AliyunPlayInfo.fromJson(await DioManager.instance.get(url: "/video/playInfo/$itemId/$vid", showLoading: true, params: RsaUtil.getPublicParams()));
  }

}
