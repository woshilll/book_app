import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/searchValue/search_value_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchValueScreen extends GetView<SearchValueController> {
  const SearchValueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(controller.site!.trArgs([controller.keyword!]))),
      onWebViewCreated: (webController) {
        controller.webViewController = webController;
      },
      // onWebViewCreated: (WebViewController wController) {
      //   controller.webViewController = wController;
      // },
      // javascriptMode: JavascriptMode.unrestricted,
      // onPageStarted: (url) {
      //   Log.i("开始加载 $url");
      // },
      // onPageFinished: (url) {
      //   Log.i("结束加载 $url");
      // },
      // onProgress: (p) {
      //   Log.i(p);
      // },
      // navigationDelegate: (request) {
      //   if (!request.url.startsWith("http")) {
      //     return NavigationDecision.prevent;
      //   }
      //   return NavigationDecision.navigate;
      // },
    );
  }
}
