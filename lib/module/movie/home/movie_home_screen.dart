import 'package:book_app/log/log.dart';
import 'package:book_app/model/video/video.dart';
import 'package:book_app/module/movie/home/movie_home_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MovieHomeScreen extends GetView<MovieHomeController> {
  const MovieHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  Widget _body(context) {
    return GetBuilder<MovieHomeController>(
      id: "body",
      builder: (controller) {
        if (!controller.showShimmer) {
          return SingleChildScrollView(
            child: Column(
              children: _widgets(context),
            ),
          );
        } else {
          return _shimmer(context);
      }
      },
    );
  }

  List<Widget> _widgets(context, {bool isShimmer = false}) {
    List<Widget> list = [];
    list.add(SizedBox(
      height: MediaQuery
          .of(context)
          .padding
          .top + 10,
    ));
    list.add(SizedBox(
      height: 200,
      child: Swiper(
        itemBuilder: (context, index) {
          return isShimmer ?
          Container(color: Colors.white,) :
          GestureDetector(
            child: Container(
                color: Colors.black.withOpacity(.8),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CachedNetworkImage(
                          imageUrl: "${controller.videoIndex.carouselList![index]
                              .coverImgBig ?? controller.videoIndex.carouselList![index]
                              .coverImg}", fit: controller.videoIndex.carouselList![index]
                          .coverImgBig == null ? BoxFit.fitHeight : BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text("${controller.videoIndex.carouselList![index]
                            .name}", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),),
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(      //渐变位置
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: [0.0, 1.0],         //[渐变起始点, 渐变结束点]
                                //渐变颜色[始点颜色, 结束颜色]
                                colors: [Colors.black, Colors.transparent]
                            )
                        ),
                      ),
                    )
                  ],
                )),
            onTap: () {
              if (!isShimmer) {
                controller.toInfo(controller.videoIndex.carouselList![index].id);
              }
            },
          );
        },
        itemCount: isShimmer ? 3 : controller.videoIndex.carouselList!.length,
        viewportFraction: .8,
        scale: .9,
        autoplay: true,
      ),
    ));
    list.add(const SizedBox(height: 10,));
    list.addAll(_item("热门", controller.videoIndex.hotList!, isShimmer: isShimmer));
    list.addAll(_item("影视", controller.videoIndex.movieList!, isShimmer: isShimmer));
    list.addAll(_item("电视剧", controller.videoIndex.tvList!, isShimmer: isShimmer));
    list.addAll(_item("动漫", controller.videoIndex.animeList!, isShimmer: isShimmer));
    return list;
  }

  List<Widget> _item(String label, List<Video> data, {bool isShimmer = false}) {
    return [
      Container(
        height: 40,
        color: isShimmer ? Colors.white : Colors.black.withOpacity(.3),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: Text(isShimmer ? "" : label),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                alignment: Alignment.centerRight,
                child: Text(isShimmer ? '' : '更多 >'),
              ),
            )
          ],
        ),
      ),
      SizedBox(
          height: 190,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                width: 110,
                padding: const EdgeInsets.only(left: 10),
                child:
                isShimmer ?
                    Container(color: Colors.white,) :
                Column(
                  children: [
                    GestureDetector(
                      child: CachedNetworkImage(
                        imageUrl: "${data[index].coverImg}", fit: BoxFit.cover, height: 150,),
                      onTap: () {
                        if (!isShimmer) {
                          controller.toInfo(data[index].id);
                        }
                      },
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Text("${data[index].name}", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, height: 1), maxLines: 1,),
                      ),
                    )
                  ],
                ),
              );
            },
            itemCount: isShimmer ? 5 : data.length,
          )
      )
    ];
  }

  Widget _shimmer(context) {
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        enabled: true,
        child: SingleChildScrollView(
          child: Column(
            children: _widgets(context, isShimmer: true),
          ),
        ),
      ),
    );
  }
}
