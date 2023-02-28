import 'dart:io';

import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/bottom_bar_build.dart';
import 'package:book_app/util/dialog_build.dart';
import 'package:book_app/util/future_do.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:book_app/util/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_app/model/book/book.dart';

class BookHomeScreen extends GetView<BookHomeController> {
  const BookHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("书架"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor(),
      ),
      backgroundColor: backgroundColor(),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: Colors.grey[800],),
        GetBuilder<BookHomeController>(
          id: "parseProcess",
          builder: (controller) {
            if (controller.parseNow) {
              return LinearProgressIndicator(
                value: controller.parseProcess / 100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              );
            } else {
              return Container();
            }
          },
        ),
        Expanded(
          child: GetBuilder<BookHomeController>(
            id: 'bookList',
            builder: (controller) {
              int count = controller.books.length +
                  (controller.localBooks.isEmpty ? 0 : 1);
              return Container(
                margin: const EdgeInsets.only(left: 25, right: 25, top: 15),
                child: ScrollConfiguration(
                  behavior: NoShadowScrollBehavior(),
                  child: GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 5,
                          childAspectRatio: .65),
                      itemCount: count + 1,
                      itemBuilder: (context, index) {
                        if (controller.localBooks.isNotEmpty) {
                          if (index == 0) {
                            return _localWidget(context);
                          }
                        }
                        if (index == count) {
                          return _addBookWidget(context);
                        }
                        return _networkBookWidget(context, index);
                      }),
                ),
              );
            },
          ),
        ),
        GetBuilder<BookHomeController>(
          id: BookHomeRefreshKey.networkParse,
          builder: (controller) {
            if (controller.needParseUrlList.isNotEmpty) {
              return GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("${controller.needParseUrlList.first["name"] ?? "网络小说"}解析",
                          style: TextStyle(color: textColor()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Text(controller.needParseUrlList.first["page"] == null ? "点击取消" : "第${controller.needParseUrlList.first["page"]}页", style: TextStyle(color: textColor()),),
                    ],
                  ),
                ),
                onTap: () {
                  controller.killParse();
                },
                behavior: HitTestBehavior.opaque,
              );
            }
            return const SizedBox();
          },
        ),
        const SizedBox(height: 16,),
      ],
    );
  }

  Widget _bookImageWidget(context, index) {
    String? img = controller.books[index].indexImg;
    if (img == null || img.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
        alignment: Alignment.topCenter,
        child: Text(
          "${controller.books[index].name}",
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor() ?? Colors.black54),
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: backgroundColorL2() ?? Colors.grey[200]
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: "${controller.books[index].indexImg}",
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      errorWidget: (context, url, error) {
        return Card(
          color: backgroundColorL2() ?? Colors.grey[200],
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "无封面\n\n${controller.books[index].name}",
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor()),
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        );
      },
    );
  }

  Widget _networkBookWidget(context, index) {
    if (controller.localBooks.isNotEmpty) {
      index = index - 1;
    }
    return Column(
      children: [
        Expanded(
            child: Card(
              color: backgroundColorL2(),
              child: InkWell(
                child: _bookImageWidget(context, index),
                borderRadius: BorderRadius.circular(4),
                onLongPress: () {
                  _longPressBook(controller.books[index]);
                },
                onTap: () =>
                    controller.getBookInfo(controller.books[index]),
              ),
            )),
        Text("${controller.books[index].name}",
            style: TextStyle(
                fontSize: 12,
                color: textColor()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis)
      ],
    );
  }

  Widget _addBookWidget(context) {
    return Column(
      children: [
        Expanded(
            child: Card(
              color: backgroundColorL2() ?? Colors.grey[200],
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(Icons.add, color: textColor() ?? Colors.black54, size: 45,),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                onTap: () {
                  _showSelect();
                },
              ),
            ),),
        const Text("新增",
            style: TextStyle(
                fontSize: 12, color: Colors.transparent),
            maxLines: 1,
            overflow: TextOverflow.ellipsis)
      ],
    );
  }

  _handleDelete(Book book) async {
    Get.dialog(DialogBuild(
        "温馨提示",
        Text.rich(
          TextSpan(text: "你确定要删除", children: [
            TextSpan(
                text: "${book.name}",
                style: const TextStyle(color: Colors.redAccent)),
            const TextSpan(text: "吗?")
          ],
            style: TextStyle(color: textColor())
          ),
        ), confirmFunction: () async {
      controller.deleteBook(book);
      Get.back();
    }));
  }

  Widget _localWidget(context) {
    double width = (MediaQuery.of(context).size.width - 130) / 3;
    double height = width / .65;
    width = (width - 15) / 2;
    height = (height - 40) / 2;
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            child: Card(
              color: backgroundColorL2() ?? Colors.grey[200],
              child: Container(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 8),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: width / height),
                  itemBuilder: (context, index) {
                    return Container(
                      child: const Icon(Icons.menu_book_outlined),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          color: textColor() ?? Colors.grey[350]),
                    );
                  },
                  itemCount: (controller.localBooks.length > 4
                      ? 4
                      : controller.localBooks.length),
                ),
              ),
            ),
            onTap: () {
              Get.bottomSheet(_localBookModal());
            },
          ),
        ),
        Text("本地书籍 : ${controller.localBooks.length}",
            style: TextStyle(
                fontSize: 12,
                color: textColor()),
            maxLines: 1,
            overflow: TextOverflow.ellipsis)
      ],
    );
  }

  _localBookModal() {
    return BottomBarBuild(
      "本地书籍",
      controller.localBooks.map<BottomBarBuildItem>((e) {
        return BottomBarBuildItem("", () {
          FutureDo.doAfterExecutor300(() => controller.getBookInfo(e),
              preExecutor: () => Get.back());
        }, longFunction: () {
          Get.back();
          _longPressBook(e);
        },
            titleWidget: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: textColor(),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${e.name}",
                          style: TextStyle(
                              color: textColor(), fontSize: 14),
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "已读 : ${e.curTotal}",
                          style: TextStyle(color: textColor()),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
      }).toList(),
    );
  }

  getFileSize(String? url) {
    if (url == null || url.isEmpty) {
      return "未知";
    }
    try {
      int length = File(url).lengthSync();
      return "${(length / 1024 / 1024).toStringAsFixed(2)}M";
    } catch (err) {
      return "未知";
    }
  }

  _longPressBook(Book book) {
    Get.bottomSheet(BottomBarBuild(
      "选项",
      [
        BottomBarBuildItem(
          "重命名",
          () {
            Get.back();
            _rename(book);
          },
          longFunction: () {
            Get.back();
          },
        ),
        BottomBarBuildItem("", () {
          Get.back();
          _handleDelete(book);
        }, longFunction: () {
          Get.back();
        },
            titleWidget: const Text(
              "删除",
              style: TextStyle(color: Colors.redAccent),
            ))
      ],
    ));
  }

  void _rename(Book book) {
    TextEditingController textEditingController = TextEditingController();
    Get.dialog(DialogBuild(
        "重命名",
        TextField(
          controller: textEditingController,
          autofocus: true,
          cursorColor: textColor(),
          style: TextStyle(color: textColor()),
          decoration: InputDecoration(
            hintText: book.name,
            hintStyle: TextStyle(color: textColor()),
          ),
        ), confirmFunction: () async {
          var text = textEditingController.text.trim();
          if (text.isNotEmpty && text.length > 20) {
            Toast.toast(toast: "名字长度最长20");
            return;
          }
          Get.back();
          if (text.isNotEmpty) {
            await controller.updateBookName(book.id!, text);
          }
    }));
  }

  void _showSelect() {
    Get.bottomSheet(BottomBarBuild(
      "选项",
      [
        BottomBarBuildItem(
          "如何使用?",
              () async{
            Get.back();
            Get.dialog(DialogBuild(
                "如何使用?",
                Text.rich(
                  TextSpan(children: const [
                    TextSpan(
                        text: "1. 本地导入，选择对应的txt文件即可导入，文件中需包含第x章，否则可能无法导入成功\n\n",
                    ),
                    TextSpan(
                      text: "2. 链接导入，通过复制链接再返回到APP中即可解析链接。注：最好解析笔趣阁等网站",
                    ),
                  ],
                      style: TextStyle(color: textColor())
                  ),
                ), confirmFunction: () async {
              Get.back();
            }));
          },
          longFunction: () {
            Get.back();
          },
        ),
        BottomBarBuildItem(
          "本地导入",
              () async{
                Get.back();
                await controller.manageChoose("1");
          },
          longFunction: () {
            Get.back();
          },
        ),
        BottomBarBuildItem("解析链接", () async{
          Get.back();
          await controller.manageChoose("2");
        }, longFunction: () {
          Get.back();
        },)
      ],
    ));
  }
}
