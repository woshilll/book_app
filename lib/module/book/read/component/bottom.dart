import 'dart:async';

import 'package:book_app/module/book/read/component/battery.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

bottom(context) async {
  // 计算进度
  ReadController controller = Get.find();
  controller.calReadProgress();
  controller.bottomType = "1";
  Navigator.of(context)
      .push(PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 100),
          pageBuilder: (context, animation, secondaryAnimation) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: GestureDetector(
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          height: MediaQuery.of(context).padding.top,
                          color: Colors.black,
                        )
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: MediaQuery.of(context).padding.top,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15),
                        child: battery(),
                      )
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 56,
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: Container(
                                margin: const EdgeInsets.only(left: 15),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: const Icon(
                                        Icons.arrow_back_ios,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        controller.popRead();
                                      },
                                    ),
                                    Container(
                                      margin:
                                      const EdgeInsets.only(left: 15),
                                      child: Text(
                                        "${controller.book!.name!.length > 10 ? controller.book!.name!.substring(0, 10) : controller.book!.name}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.centerRight,
                                margin: const EdgeInsets.only(right: 15),
                                child: const Icon(
                                  Icons.share_outlined,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                await _share(controller);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Opacity(
                          opacity: 1,
                          child: GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 16),
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4))),
                              child: Column(
                                children: [
                                  GetBuilder<ReadController>(
                                    id: 'bottomType',
                                    builder: (controller) {
                                      return _bottomType(controller);
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Column(
                                                children: const [
                                                  Icon(Icons.library_books,
                                                      size: 24,
                                                      color: Colors.white),
                                                  Text("目录",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14))
                                                ],
                                              ),
                                            ),
                                            onTap: () async{
                                              Navigator.of(context).pop();
                                              await controller.openDrawer();
                                            },
                                          ),
                                        ),
                                        GetBuilder<ReadController>(
                                          id: "bottomType",
                                          builder: (controller) {
                                            return Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.wb_sunny,
                                                          size: 24,
                                                          color: controller.bottomType == "2" ? Theme.of(context).primaryColor : Colors.white),
                                                      Text("亮度",
                                                          style: TextStyle(
                                                              color: controller.bottomType == "2" ? Theme.of(context).primaryColor : Colors.white,
                                                              fontSize: 14))
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  controller
                                                      .changeBottomType("2");
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                        GetBuilder<ReadController>(
                                          id: "bottomType",
                                          builder: (controller) {
                                            return Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.settings,
                                                          size: 24,
                                                          color: controller.bottomType == "3" ? Theme.of(context).primaryColor : Colors.white),
                                                      Text("设置",
                                                          style: TextStyle(
                                                              color: controller.bottomType == "3" ? Theme.of(context).primaryColor : Colors.white,
                                                              fontSize: 14))
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  controller
                                                      .changeBottomType("3");
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        )),
                    GetBuilder<ReadController>(
                        id: 'bottomType',
                        builder: (controller) {
                          if (controller.bottomType == "1") {
                            return Positioned(
                              right: 15,
                              bottom: 150,
                              child: GestureDetector(
                                child: CircleAvatar(
                                  minRadius: 25,
                                  backgroundColor:
                                  Colors.black.withOpacity(.5),
                                  child: Icon(
                                    controller.isDark
                                        ? Icons.wb_sunny
                                        : Icons.nights_stay,
                                    size: 25,
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                                onTap: () => LimitUtil.throttle(
                                    controller.changeDark,
                                    durationTime: 1000),
                              ),
                            );
                          }
                          return Container();
                        })
                  ],
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light, child: child),
            );
          }
          ));
}

/// 分享
_share(ReadController controller) async{
  Get.bottomSheet(
    Card(
      color: Colors.black,
      child: SizedBox(
        height: 152,
        child: Column(
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              child: const Text("分享", style: TextStyle(height: 1, fontSize: 14),),
            ),
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            InkWell(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("分享链接", style: TextStyle(height: 1, fontSize: 14),),
              ),
              onTap: () {
                if (controller.book!.type == 2) {
                  EasyLoading.showToast("本地书籍, 无法分享链接");
                  return;
                }
                Share.share("woshilll:${controller.book!.url}");
              },
            ),
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            InkWell(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: const Text("分享文件", style: TextStyle(height: 1, fontSize: 14),),
              ),
              onTap: () {
                if (controller.book!.type == 1) {
                  EasyLoading.showToast("网络书籍, 无法分享文件");
                  return;
                }
                Share.shareFiles([controller.book!.url!]);
              },
            )
          ],
        ),
      ),
    )
  );
  // Share.share("woshilll:${controller.book!.url}");
}

Widget _bottomType(ReadController controller) {
  if (controller.bottomType == "1") {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "上一章",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            onTap: () async {
              await controller.preChapter();
            },
          ),
        ),
        Expanded(
            flex: 2,
            child: GetBuilder<ReadController>(
              id: "chapterChange",
              builder: (controller) {
                return Slider(
                  label:
                      "${controller.chapters[controller.readChapterIndex].name}",
                  divisions: controller.chapters.length,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  min: 0,
                  max: controller.chapters.length - 1,
                  value: controller.readChapterIndex + 0,
                  onChanged: (value) {
                    controller.chapterChange(value);
                  },
                  onChangeStart: (value) {},
                  onChangeEnd: (value) {
                    controller.jumpChapter(value.toInt(), clearCount: true);
                  },
                );
              },
            )),
        Expanded(
          flex: 1,
          child: GestureDetector(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "下一章",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            onTap: () => {
              LimitUtil.throttle(() async{
                await controller.nextChapter();
              })
            },
          ),
        ),
      ],
    );
  } else if (controller.bottomType == "2") {
    // 亮度调节
    return Column(
      children: [
        // 亮度,
        Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: GetBuilder<ReadController>(
                  id: "brightness",
                  builder: (controller) {
                    return Slider(
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey,
                      min: 0,
                      max: 1,
                      value: controller.brightness,
                      onChanged: (value) async {
                        await controller.setBrightness(value);
                      },
                      onChangeStart: (value) {},
                      onChangeEnd: (value) {},
                    );
                  },
                )),
            Expanded(
              flex: 1,
              child: GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        // 背景色
        Container(
          height: 30,
          margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _colors(controller),
          ),
        )
      ],
    );
  } else if (controller.bottomType == "3") {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            child: Row(
              children: const [
                Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 25,
                ),
                Text(
                  "-",
                  style:
                      TextStyle(color: Colors.white, fontSize: 30, height: 1),
                )
              ],
            ),
            onTap: () async {
              await controller.fontHeightSub();
            },
          ),
          GestureDetector(
            child: Row(
              children: const [
                Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 25,
                ),
                Text(
                  "+",
                  style:
                      TextStyle(color: Colors.white, fontSize: 16, height: 1),
                )
              ],
            ),
            onTap: () async {
              await controller.fontHeightAdd();
            },
          ),
          GetBuilder<ReadController>(
            id: 'autoPage',
            builder: (controller) {
              return Text("Auto",
                  style: TextStyle(
                      fontSize: 16,
                      color: (controller.autoPage == null ||
                              !controller.autoPage!.isActive)
                          ? Colors.white
                          : Theme.of(controller.context).primaryColor));
            },
          ),
          GestureDetector(
            child: Image.asset(
              "lib/resource/image/screen_h.png",
              width: 25,
              color: Colors.white,
            ),
            onTap: () async {
              await controller.rotateScreenChange();
            },
          ),
          GestureDetector(
            child: Container(
              padding:
                  const EdgeInsets.only(top: 3, bottom: 5, left: 10, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white)),
              child: const Text(
                "更多设置",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            onTap: () async {
              await controller.toMoreSetting();
            },
          ),
        ],
      ),
    );
  }
  return Container();
}

List<Widget> _colors(ReadController controller) {
  List<Widget> list =
      List<Widget>.generate(controller.backgroundColors.length, (index) {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: hexToColor(controller.backgroundColors[index]),
        child: Text(controller.backgroundColors[index] ==
                controller.readSettingConfig.backgroundColor
            ? "√"
            : ""),
      ),
      onTap: () {
        controller.setBackGroundColor(controller.backgroundColors[index]);
      },
    );
  });
  // Aa+ Aa-
  list.add(GestureDetector(
    child: Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      alignment: Alignment.center,
      child:
          const Text("重置", style: TextStyle(fontSize: 14, color: Colors.white)),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.white)),
    ),
    onTap: () async{
      await controller.resetReadSetting();
    },
  ));
  list.add(GestureDetector(
    child: Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      alignment: Alignment.center,
      child: const Text("自定义",
          style: TextStyle(fontSize: 14, color: Colors.white)),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.white)),
    ),
    onTap: () async {
      await controller.toSetting();
    },
  ));
  return list;
}
