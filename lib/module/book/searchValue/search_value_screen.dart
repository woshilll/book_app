import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/searchValue/search_value_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchValueScreen extends GetView<SearchValueController> {
  const SearchValueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     centerTitle: true,
    //     title: const Text("搜索结果"),
    //     elevation: 0,
    //   ),
    //   body: GetBuilder<SearchValueController>(
    //     id: "result",
    //     builder: (controller) {
    //       return ListView.separated(
    //         itemCount: controller.searchResults.length,
    //         itemBuilder: (context, index) {
    //           return Container(
    //             margin: const EdgeInsets.only(top: 15),
    //             padding: const EdgeInsets.only(left: 10, right: 10),
    //             child: GestureDetector(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   controller.buildRichText(controller.searchResults[index].label, 20, FontWeight.bold),
    //                   const SizedBox(height: 10,),
    //                   controller.buildRichText(controller.searchResults[index].description, 15, FontWeight.normal),
    //                 ],
    //               ),
    //               onTap: () {
    //                 Get.toNamed(Routes.searchValueView, arguments: {"url": controller.searchResults[index].url});
    //               },
    //             ),
    //           );
    //         },
    //         separatorBuilder: (context, index) {
    //           return Container(
    //             height: 1,
    //             margin: const EdgeInsets.only(top: 15),
    //             color: Colors.grey,
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );
    return WillPopScope(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top,),
            Expanded(
              child: _body(context),
            )
          ],
        ),
        floatingActionButton: ElevatedButton(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.search, size: 30,),
          ),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
          ),
          onPressed: () async{
            await controller.parse();
          },
        ),
      ),
      onWillPop: () async{
        await controller.pop();
        return false;
      },
    );
  }

  Widget _body(context) {
    return WebView(
      initialUrl: controller.site!.trArgs([controller.keyword!]),
      onWebViewCreated: (WebViewController wController) {
        controller.webViewController = wController;
      },
      javascriptMode: JavascriptMode.unrestricted,
      onPageStarted: (url) {
        Log.i("开始加载 $url");
      },
      onPageFinished: (url) {
        Log.i("结束加载 $url");
      },
      onProgress: (p) {
        Log.i(p);
      },
      navigationDelegate: (request) {
        if (!request.url.startsWith("http")) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    );
  }
}
