import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
            if (controller.books.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
                child: ScrollConfiguration(
                  behavior: NoShadowScrollBehavior(),
                  child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 2 / 3
                      ),
                      itemCount: controller.books.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Expanded(child: InkWell(
                              child: _bookImageWidget(context, index),
                              onLongPress: () {
                                _handleDelete(context, index);
                              },
                              onTap: () => controller.getBookInfo(index),
                            )),
                            Center(
                              child: Text("${controller.books[index].name}", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyText1!.color!), maxLines: 1, overflow: TextOverflow.ellipsis),
                            )
                          ],
                        );
                      }
                  ),
                ),
              );
            }
            return Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: 10),
              child: Text.rich(
                TextSpan(
                  text: "书架里还没有书,快去",
                  children: [
                    TextSpan(
                      text: "搜索",
                      recognizer: TapGestureRecognizer()..onTap = () {
                        controller.toSearch();
                      },
                        style: TextStyle(color: Theme.of(context).primaryColor)
                    ),
                    const TextSpan(
                        text: "吧"
                    ),
                  ],
                  style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyText1!.color)
                )
              ),
            );
          },
        )
      ],
    );
  }
  Widget _bookImageWidget(context, index) {
    String? img = controller.books[index].indexImg;
    if (img == null || img.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: Text("本地书籍\n\n${controller.books[index].name}", textAlign: TextAlign.center,),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: Colors.grey
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
        return Container(
          alignment: Alignment.center,
          child: Text("本地书籍\n\n${controller.books[index].name}", textAlign: TextAlign.center,),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: Colors.grey
          ),
        );
      },
    );

  }
  Future<void> _handleDelete(context, index) async{
    Book book = controller.books[index];
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
                  controller.deleteBook(index);
                  Navigator.of(context).pop();
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
          child: Text("多选"),
          value: "2",
        ),
      ],
      offset: const Offset(20, 30),
      onSelected: (value) async{
        await controller.manageChoose(value);
      },
    );
  }
}
