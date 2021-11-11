import 'package:book_app/api/video_api.dart';
import 'package:book_app/model/video/video_index.dart';
import 'package:get/get.dart';

class MovieHomeController extends GetxController {

  VideoIndex videoIndex = VideoIndex.defaultValue();
  bool showShimmer = true;


  @override
  void onReady() async{
    super.onReady();
    // videoIndex = await VideoApi.getIndex();
    // showShimmer = false;
    // update(["body"]);
  }
}
