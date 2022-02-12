import 'dart:io';

import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/bar_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:book_app/util/size_fit_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:book_app/model/book/book.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BookHomeScreen extends GetView<BookHomeController> {
  const BookHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeFitUtil.initialize(context);
    ScreenUtil.init(BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height));
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
      floatingActionButton: ElevatedButton(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.search, size: 30,),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(const CircleBorder()),
          backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
        ),
        onPressed: () {
          controller.toSearch();
        },
      ),
    );
  }
  Widget _body(context) {
    return Stack(
      children: [
        GetBuilder<BookHomeController>(
          id: 'bookList',
          builder: (controller) {
            if (controller.books.isNotEmpty || controller.localBooks.isNotEmpty) {
              int count = controller.books.length + (controller.localBooks.isEmpty ? 0 : 1);
              return Container(
                margin: const EdgeInsets.only(left: 25, right: 25, top: 15),
                child: ScrollConfiguration(
                  behavior: NoShadowScrollBehavior(),
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 5,
                          childAspectRatio: .65
                      ),
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
                            Expanded(child: InkWell(
                              child: _bookImageWidget(context, index),
                              onLongPress: () {
                                _handleDelete(context, controller.books[index]);
                              },
                              onTap: () => controller.getBookInfo(controller.books[index]),
                            )),
                            Text("${controller.books[index].name}", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyText1!.color!), maxLines: 1, overflow: TextOverflow.ellipsis)
                          ],
                        );
                      }
                  ),
                ),
              );
            }
            return GestureDetector(
              child: Card(
                color: Colors.grey[200],
                  margin: const EdgeInsets.only(top: 15, left: 10),
                child: Container(
                  alignment: Alignment.center,
                  width: (MediaQuery.of(context).size.width - 30) / 3,
                  height: (MediaQuery.of(context).size.width - 30) / 2,
                  child: Icon(Icons.add, color: Theme.of(context).textTheme.bodyText1!.color, size: 40,),
                )
              ),
              onTap: () {
                controller.toSearch();
              },
            );
          },
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
          child: Text("${controller.books[index].name}", textAlign: TextAlign.center,style: const TextStyle(color: Colors.black54),),
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
          image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return Card(
          child: Container(
            alignment: Alignment.center,
            child: Text("${controller.books[index].type == 2 ? '本地书籍' : '无封面'}\n\n${controller.books[index].name}", textAlign: TextAlign.center,),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        );
      },
    );

  }
  Future<void> _handleDelete(context, Book book, {int popTimes = 1}) async{
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: const Text("温馨提示"),
            titlePadding: const EdgeInsets.all(10),
            titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
            content: Text.rich(
              TextSpan(
                text: "你确定要删除 ",
                children: [
                  TextSpan(
                    text: "${book.name}",
                    style: const TextStyle(color: Colors.redAccent)
                  ),
                  const TextSpan(
                      text: "吗?"
                  )
                ]
              ),
            ),
            contentPadding: const EdgeInsets.all(10),
            //中间显示内容的文本样式
            contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            actions: [
              ElevatedButton(
                child: const Text("取消"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text("确定"),
                onPressed: () {
                  controller.deleteBook(book);
                  for (var i = 0; i < popTimes; i++) {
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        }
    );
  }

  Widget _managePop() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          child: Text("导入"),
          value: "1",
        ),
        const PopupMenuItem<String>(
          child: Text("设置"),
          value: "3",
        ),
      ],
      offset: const Offset(20, 30),
      onSelected: (value) async{
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
                      childAspectRatio: width / height
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      child: const FaIcon(FontAwesomeIcons.bookOpen),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Color(0xFFBDBDBD)
                      ),
                    );
                  },
                  itemCount: (controller.localBooks.length > 4 ? 4 : controller.localBooks.length),
                ),
              ),
            ),
            onTap: () {
              transparentBar();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => _localBookModal(),
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text("本地书籍 : ${controller.localBooks.length}", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyText1!.color!), maxLines: 1, overflow: TextOverflow.ellipsis),
        )
      ],
    );
  }

  _localBookModal() {
    return Container(
      color: Colors.white,
      height: 51 * (controller.localBooks.length + 1) + 16,
      child: Column(
        children: [
          Container(
            height: 50,
            alignment: Alignment.center,
            child: const Text("本地书籍", style: TextStyle(color: Colors.black, fontSize: 16),),
          ),
          Container(height: 1, color: Colors.grey,),
          Expanded(
            child: ListView.separated(
              itemCount: controller.localBooks.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: const FaIcon(FontAwesomeIcons.bookOpen, color: Colors.black,),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("${controller.localBooks[index].name}", style: const TextStyle(color: Colors.black, fontSize: 14),),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text("大小 : ${getFileSize(controller.localBooks[index].url)}", style: const TextStyle(color: Colors.grey),),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.getBookInfo(controller.localBooks[index]);
                  },
                  onLongPress: () {
                    _handleDelete(context, controller.localBooks[index], popTimes: 2);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 1,
                  color: Colors.grey,
                );
              },
            ),
          )

        ],
      ),
    );
  }

  getFileSize(String? url) {
    if (url == null || url.isEmpty) {
      return "未知";
    }
    try {
      int length = File(url).lengthSync();
      return "${(length / 1024 / 1024).toStringAsFixed(2)}M";
    } catch(err) {
      return "未知";
    }
  }
}
