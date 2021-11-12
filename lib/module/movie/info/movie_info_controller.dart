import 'package:book_app/api/video_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/video/aliyun_play_info.dart';
import 'package:book_app/model/video/video_info.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/encrypt_util.dart';
import 'package:book_app/util/save_util.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MovieInfoController extends GetxController {

  int? videoId;
  VideoInfo? videoInfo;
  VideoPlayerController? playerController;
  bool isShimmer = true;
  AliyunPlayInfo? aliyunPlayInfo;
  @override
  void onInit() {
    super.onInit();
    videoId = Get.arguments["id"];
  }

  @override
  void onReady() async{
    super.onReady();
    videoInfo = await VideoApi.getInfo(videoId);
    isShimmer = false;
    update(["videoInfoBody"]);
  }

  getPlayInfo() async{
    var vid = videoInfo!.itemList![0].vid;
    var itemId = videoInfo!.itemList![0].id;
    aliyunPlayInfo = await VideoApi.getPlayInfo(vid, itemId);
    var encryptToken = await EncryptUtil.encryptToken(SaveUtil.getString(Constant.token)!.replaceAll("\"", ""));
    encryptToken = encryptToken.replaceAll("%2B", "+");
    String url = aliyunPlayInfo!.playInfoList![0].playURL! + "&MtsHlsUriToken=$encryptToken";
    playerController = VideoPlayerController.network(url);
    await playerController!.initialize();
    update(["videoInfoBody"]);
  }
}
