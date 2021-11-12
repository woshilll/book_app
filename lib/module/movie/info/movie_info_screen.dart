import 'package:book_app/log/log.dart';
import 'package:book_app/module/movie/info/movie_info_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MovieInfoScreen extends GetView<MovieInfoController> {
  const MovieInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("详情"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return GetBuilder<MovieInfoController>(
      id: "videoInfoBody",
      builder: (controller) {
        if (controller.isShimmer) {
          return Container();
        }
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: _cover(context),
            ),
            SizedBox(height: 10,),
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    child: Chip(
                      label: Text(controller.videoInfo!.itemList![index].name!),
                    ),
                  );
                },
                itemCount: controller.videoInfo!.itemList!.length,
              ),
            )
          ],
        );
      },
    );
  }

  Widget _cover(context) {
    if (controller.playerController != null && controller.playerController!.value.isInitialized) {
      Log.i(controller.playerController!.value.aspectRatio);
      Log.i(4 / 3);
      // controller.playerController!.play();
      return VideoPlayer(controller.playerController!);
    }
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: CachedNetworkImage(imageUrl: controller.videoInfo!.video!.coverImg!, fit: BoxFit.cover,),
        ),
        Positioned(
          child: Center(
            child: GestureDetector(
              child: Icon(Icons.play_circle_filled, size: 40,),
              onTap: () {
                controller.getPlayInfo();
              },
            ),
          ),
        )
      ],
    );
  }
}
