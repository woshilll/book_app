import 'dart:io';

import 'package:book_app/module/book/home/book_home_controller.dart';
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
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: _managePop(),
            ),
          )
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<BookHomeController>(
          id: "parseProcess",
          builder: (controller) {
            if (controller.parseNow) {
              return LinearProgressIndicator(
                value: controller.parseProcess / 100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              );
              //   FloatingActionButton(
              //   onPressed: null,
              //   child: Text(
              //     "${controller.parseProcess.toStringAsFixed(2)}%",
              //     style: const TextStyle(color: Colors.white),
              //   ),
              // );
            } else {
              return Container();
            }
          },
        ),
        Flexible(
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
                      itemCount: count,
                      itemBuilder: (context, index) {
                        if (controller.localBooks.isNotEmpty) {
                          if (index == 0) {
                            return _localWidget(context);
                          }
                          index = index - 1;
                        }
                        return Column(
                          children: [
                            Expanded(
                                child: InkWell(
                                  child: _bookImageWidget(context, index),
                                  onLongPress: () {
                                    _longPressBook(controller.books[index]);
                                  },
                                  onTap: () =>
                                      controller.getBookInfo(controller.books[index]),
                                )),
                            Text("${controller.books[index].name}",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)
                          ],
                        );
                      }),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _bookImageWidget(context, index) {
    String? img = controller.books[index].indexImg;
    if (img == null || img.isEmpty) {
      return Card(
        color: Colors.grey[200],
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 15),
          alignment: Alignment.topCenter,
          child: Text(
            "${controller.books[index].name}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
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
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "无封面\n\n${controller.books[index].name}",
              textAlign: TextAlign.center,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        );
      },
    );
  }

  _handleDelete(Book book) async {
    Get.dialog(DialogBuild(
        "温馨提示",
        Text.rich(
          TextSpan(text: "你确定要删除 ", children: [
            TextSpan(
                text: "${book.name}",
                style: const TextStyle(color: Colors.redAccent)),
            const TextSpan(text: "吗?")
          ]),
        ), confirmFunction: () async {
      controller.deleteBook(book);
      Get.back();
    }));
  }

  Widget _managePop() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          child: Text("本地导入"),
          value: "1",
        ),
        const PopupMenuItem<String>(
          child: Text("导入选项"),
          value: "2",
        ),
      ],
      offset: const Offset(20, 30),
      onSelected: (value) async {
        await controller.manageChoose(value);
      },
    );
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
              color: Colors.grey[200],
              child: Container(
                margin: const EdgeInsets.only(left: 5, right: 5, top: 8),
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
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Color(0xFFBDBDBD)),
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
        Container(
          alignment: Alignment.centerLeft,
          child: Text("本地书籍 : ${controller.localBooks.length}",
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyText1!.color!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        )
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
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: Colors.black,
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
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "大小 : ${getFileSize(e.url)}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ));
      }).toList(),
      backgroundColor: Colors.white,
      titleColor: Colors.black,
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
      backgroundColor: Colors.white,
      titleColor: Colors.black,
    ));
  }

  void _rename(Book book) {
    TextEditingController textEditingController = TextEditingController();
    Get.dialog(DialogBuild(
        "重命名",
        TextField(
          controller: textEditingController,
          autofocus: true,
          decoration: InputDecoration(hintText: book.name),
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
}
