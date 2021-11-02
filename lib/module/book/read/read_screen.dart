import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/home/component/drag_overlay.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/audio/text_player_handler.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'component/custom_drawer.dart';

class ReadScreen extends GetView<ReadController> {
  const ReadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      key: controller.scaffoldKey,
      body: WillPopScope(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: GetBuilder<ReadController>(
                id: "backgroundColor",
                builder: (controller) {
                  return Container(
                    color: hexToColor(
                        controller.readSettingConfig.backgroundColor),
                  );
                },
              ),
            ),
            _body(context),
          ],
        ),
        onWillPop: () async {
          controller.pop();
          return false;
        },
      ),
      drawer: _drawer(context),
      onDrawerChanged: (value) {
        controller.calReadProgress();
        if (value && !controller.drawerFlag) {
          controller.drawerFlag = true;
          Timer(const Duration(milliseconds: 300), () {
            if (controller.scaffoldKey.currentState!.isDrawerOpen) {
              if (controller.menuController.offset + 500 <
                  (controller.readChapterIndex + 1) * 41) {
                controller.menuController
                    .jumpTo(controller.readChapterIndex * 41);
              }
            }
            controller.drawerFlag = true;
          });
        } else {
          controller.drawerFlag = false;
        }
      },
    );
  }

  Widget _body(context) {
    return GestureDetector(
      child: GetBuilder<ReadController>(
        id: "content",
        builder: (controller) {
          return Listener(
            child: PageView.builder(
              controller: controller.contentPageController,
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                return _content(context, index);
              },
              onPageChanged: (index) async {
                controller.pageIndex = index;
                if (index + 10 >= controller.pages.length &&
                    !controller.loading) {
                  await controller.pageChangeListen(index);
                }
              },
            ),
            onPointerDown: (e) {
              controller.autoPageCancel();
              controller.xMove = e.position.dx;
            },
            onPointerUp: (e) async {
              double move = e.position.dx - controller.xMove;
              // 滑动了五十距离, 且当前为0
              if (move > 50 && controller.pageIndex == 0) {
                await controller.prePage();
              } else if (move < -50 &&
                  controller.pageIndex == controller.pages.length - 1) {
                await controller.nextPage();
              }
            },
          );
        },
      ),
      onTapUp: (e) async {
        controller.screenWidth = MediaQuery.of(context).size.width;
        if (e.globalPosition.dx < controller.screenWidth / 3) {
          await controller.prePage();
        } else if (e.globalPosition.dx > (controller.screenWidth / 3 * 2)) {
          if (!controller.loading) {
            await controller.nextPage();
          }
        } else {
          // 中间
          _showBottom(context);
        }
      },
    );
  }

  Widget _content(context, index) {
    return Stack(
      children: [
        Positioned(
            top: MediaQuery.of(context).padding.top,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                  left: ((MediaQuery.of(context).size.width %
                                  controller.pages[index].wordWith) +
                              controller.pages[index].wordWith) /
                          2 +
                      MediaQuery.of(context).padding.left),
              child: Column(
                children: [
                  if (controller.pages[index].index == 1)
                    Container(
                      height: 80,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${controller.pages[index].chapterName}\n",
                        style: TextStyle(
                            color: controller.pages[index].style.color,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text.rich(
                    TextSpan(
                        text: controller.pages[index].content,
                        style: controller.pages[index].style),
                  )
                ],
              ),
            )),
        Positioned(
          bottom: 16,
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "${controller.pages[index].chapterName}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 10,
          child: Text(
            "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _drawer(context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Opacity(
          opacity: 1,
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: CustomDrawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 15),
                    child: GetBuilder<ReadController>(
                      id: 'content',
                      builder: (controller) {
                        return Text(
                          "共${controller.chapters.length + 1}章",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          child: ScrollConfiguration(
                            behavior: NoShadowScrollBehavior(),
                            child: Scrollbar(
                              child: GetBuilder<ReadController>(
                                id: 'content',
                                builder: (controller) {
                                  return ListView.separated(
                                    controller: controller.menuController,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        child: Container(
                                          height: 40,
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "${controller.chapters[index].name}",
                                            style:
                                                controller.readChapterIndex ==
                                                        index
                                                    ? const TextStyle(
                                                        color: Colors.lightBlue)
                                                    : const TextStyle(
                                                        color: Colors.grey),
                                          ),
                                        ),
                                        onTap: () async {
                                          await controller.jumpChapter(index);
                                        },
                                      );
                                    },
                                    itemCount: controller.chapters.length,
                                    cacheExtent: 200,
                                    separatorBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Divider(
                                            height: 1.0, color: Colors.grey),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              widthPercent: 0.7,
            ),
          ),
        ));
  }

  _showBottom(context) {
    // 计算进度
    controller.calReadProgress();
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
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
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).padding.top + 56,
                      color: Colors.black,
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: Container(
                                margin: const EdgeInsets.only(left: 15),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      child: const Icon(
                                        Icons.arrow_back_ios,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        controller.pop();
                                      },
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: Text(
                                        "${controller.book.name!.length > 10 ? controller.book.name!.substring(0, 10) : controller.book.name}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.centerRight,
                                margin: EdgeInsets.only(right: 15),
                                child: const Icon(
                                  Icons.headset,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                await controller.play();
                              },
                            )
                          ],
                        ),
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
                                    return _bottomType();
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
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            controller.openDrawer();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: const [
                                                Icon(Icons.wb_sunny,
                                                    size: 24,
                                                    color: Colors.white),
                                                Text("亮度",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14))
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            controller.changeBottomType("2");
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: const [
                                                Icon(Icons.settings,
                                                    size: 24,
                                                    color: Colors.white),
                                                Text("设置",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14))
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            controller.changeBottomType("3");
                                          },
                                        ),
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
                                backgroundColor: Colors.black.withOpacity(.5),
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
            child: child,
          );
        }));
  }

  Widget _bottomType() {
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
                      controller.jumpChapter(value.toInt());
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
              onTap: () async {
                await controller.nextChapter();
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
                        label:
                            "${controller.chapters[controller.readChapterIndex].name}",
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
              children: _colors(),
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
                padding: const EdgeInsets.only(
                    top: 3, bottom: 5, left: 10, right: 10),
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

  List<Widget> _colors() {
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
        child: const Text("重置",
            style: TextStyle(fontSize: 14, color: Colors.white)),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: Colors.white)),
      ),
      onTap: () => controller.setBackGroundColor("#FFF2E2"),
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
}
