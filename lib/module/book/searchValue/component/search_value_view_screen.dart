import 'package:book_app/module/book/searchValue/component/search_value_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchValueViewScreen extends GetView<SearchValueViewController> {
  const SearchValueViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SearchValueViewController>(
        id: "view",
        builder: (controller) {
          // if (controller.url.isNotEmpty) {
            return WebView(
              initialUrl: controller.url,
            );
          // }
          // return Container();
        },
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: ElevatedButton(
          child: const Text("加入书架", style: TextStyle(fontSize: 14)),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(const CircleBorder()),
          ),
          onPressed: () {
            controller.addBook();
          },
        ),
      ),
    );
  }

}