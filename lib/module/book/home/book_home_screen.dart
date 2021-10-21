import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_app/model/book/book.dart';

class BookHomeScreen extends GetView<BookHomeController> {
  const BookHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("书架"),
        centerTitle: true,
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
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: ElevatedButton(
          child: const Text("搜书", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(const CircleBorder()),
          ),
          onPressed: () {
            Get.toNamed(Routes.search);
          },
        ),
      ),
    );
  }
  Widget _body(context) {
    return GetBuilder<BookHomeController>(
      id: 'bookList',
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
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
                      child: Text("${controller.books[index].name}"),
                    )
                  ],
                );
              }
          ),
        );
      },
    );
  }
  Widget _bookImageWidget(context, index) {
    if (controller.books[index].indexImg == null) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.blue,
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
        Log.e(error);
        return Container(
          color: Colors.pink,
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
    );
  }
}
