import 'package:book_app/api/video_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/video/video_index.dart';
import 'package:book_app/route/routes.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MovieHomeController extends GetxController {

  VideoIndex videoIndex = VideoIndex.defaultValue();
  bool showShimmer = true;


  @override
  void onReady() async{
    super.onReady();
    videoIndex = await VideoApi.getIndex();
    showShimmer = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    update(["body"]);
  }


  toInfo(id) {
    Get.toNamed(Routes.movieInfo, arguments: {"id": id})!.then((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}
