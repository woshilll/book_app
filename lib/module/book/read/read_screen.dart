import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'component/custom_drawer.dart';

class ReadScreen extends GetView<ReadController> {
  const ReadScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.keyboardListen();
    controller.context = context;
    return Scaffold(
      key: controller.scaffoldKey,
      body: WillPopScope(
        child: Stack(
          children: [
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
              if (controller.menuController.offset + 500 < (controller.readChapterIndex + 1) * 41) {
                controller.menuController.jumpTo(controller.readChapterIndex * 41);
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
          return PageView.builder(
            controller: controller.contentPageController,
            itemCount: controller.pages.length,
            itemBuilder: (context, index) {
              return _content(context, index);
            },
            onPageChanged: (index) async{
              controller.pageIndex = index;
              if (index + 10 >= controller.pages.length && !controller.loading) {
                await controller.pageChangeListen(index);
              }
            },
          );
        },
      ),
      onTapUp: (e) {
        if (controller.screenWidth <= 0) {
          controller.screenWidth = MediaQuery.of(context).size.width;
        }
        if (e.globalPosition.dx < controller.screenWidth / 3) {
          controller.prePage();
        } else if (e.globalPosition.dx > (controller.screenWidth / 3 * 2)) {
          controller.nextPage();
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
              padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width % controller.pages[index].wordWith) / 2),
              child: Text.rich(
                TextSpan(
                    text: controller.pages[index].content,
                    style: controller.pages[index].style),
              ),
            )),
        Positioned(
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "${controller.pages[index].chapterName}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
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
          opacity: 0.9,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: CustomDrawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10, left: 15),
                    child: GetBuilder<ReadController>(
                      id: 'content',
                      builder: (controller) {
                        return Text("共${controller.chapters.length + 1}章", style: const TextStyle(fontSize: 14),);
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
                                          padding: const EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Text("${controller.chapters[index].name}", style: controller.readChapterIndex == index ? const TextStyle(color: Colors.lightBlue) : const TextStyle(),),
                                        ),
                                        onTap: () async{
                                          await controller.jumpChapter(index);
                                        },
                                      );
                                    },
                                    itemCount: controller.chapters.length,
                                    cacheExtent: 200,
                                    separatorBuilder: (context, index) {
                                      return Divider(height: 1.0, color: Colors.grey[300]);
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
        )
    );
  }

  _showBottom(context) {
    // 计算进度
    controller.calReadProgress();
    Navigator.of(context).push(
      PageRouteBuilder(
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
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Opacity(
                        opacity: 1,
                        child: GestureDetector(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))
                            ),
                            child: Column(
                              children: [
                                GetBuilder<ReadController>(
                                  id: 'bottomType',
                                  builder: (controller) {
                                    return _bottomType();
                                  },
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: const [
                                                Icon(Icons.library_books, size: 24,),
                                                Text("目录", style: TextStyle(color: Colors.white, fontSize: 14))
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
                                                Icon(Icons.wb_sunny, size: 24,),
                                                Text("亮度", style: TextStyle(color: Colors.white, fontSize: 14))
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
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: const [
                                              Icon(Icons.settings, size: 24,),
                                              Text("设置", style: TextStyle(color: Colors.white, fontSize: 14))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                          },
                        ),
                      )
                  )
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
        }
      )
    );

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
                child: const Text("上一章", style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
              onTap: () async{
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
                    label: "${controller.chapters[controller.readChapterIndex].name}",
                    divisions: controller.chapters.length,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    min: 0,
                    max: controller.chapters.length - 1,
                    value: controller.readChapterIndex + 0,
                    onChanged: (value) {
                      controller.chapterChange(value);
                    },
                    onChangeStart: (value) {

                    },
                    onChangeEnd: (value) {
                      controller.jumpChapter(value.toInt());
                    },
                  );
                },
              )
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              child: Container(
                alignment: Alignment.center,
                child: const Text("下一章", style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
              onTap: () async{
                await controller.nextChapter();
              },
            ),
          ),
        ],
      );
    } else if (controller.bottomType == "2") {
      // 亮度调节
      return Container(
        child: Column(
          children: [
            // 亮度,
            Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Icon(Icons.wb_sunny, size: 16, color: Colors.white,),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 4,
                      child: GetBuilder<ReadController>(
                        id: "brightness",
                        builder: (controller) {
                          return Slider(
                            label: "${controller.chapters[controller.readChapterIndex].name}",
                            divisions: 10,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey,
                            min: 0,
                            max: 1,
                            value: controller.brightness,
                            onChanged: (value) async{
                              await controller.setBrightness(value);
                            },
                            onChangeStart: (value) {

                            },
                            onChangeEnd: (value) {
                            },
                          );
                        },
                      )
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Icon(Icons.wb_sunny, size: 30, color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 背景色
            Container(
              height: 30,
              margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    alignment: Alignment.center,
                    child: Text("自定义", style: TextStyle(fontSize: 14, color: Colors.white)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.white)
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else if (controller.bottomType == "3") {
      return Container();
    }
    return Container();
  }
}
