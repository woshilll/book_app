import 'package:book_app/module/book/searchValue/component/search_value_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchValueViewScreen extends GetView<SearchValueViewController> {
  const SearchValueViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("小说"),
        centerTitle: true,
      ),
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
          child: const Icon(Icons.add, size: 25, color: Colors.white,),
          style: ButtonStyle(
            shape: MaterialStateProperty.all(const CircleBorder()),
            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
          ),
          onPressed: () {
            controller.addBook();
          },
        ),
      ),
    );
  }

}
