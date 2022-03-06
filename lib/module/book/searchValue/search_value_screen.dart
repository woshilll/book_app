import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/searchValue/search_value_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SearchValueScreen extends GetView<SearchValueController> {
  const SearchValueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top,),
            Expanded(
              child: _body(context),
            )
          ],
        ),
        floatingActionButton: GetBuilder<SearchValueController>(
          id: "showButton",
          builder: (controller) {
            if (controller.showParseButton) {
              return ElevatedButton(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const FaIcon(FontAwesomeIcons.bookMedical, size: 30,),
                ),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(const CircleBorder()),
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                ),
                onPressed: () async{
                  await controller.parse();
                },
              );
            }
            return Container();
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
      initialUrlRequest: URLRequest(url: Uri.parse(getSites()[0][1])),
      onWebViewCreated: (webController) {
        controller.webViewController = webController;
      },
      onLoadStop: (x, y) async{
        controller.showParseButton = await _showButton();
        controller.update(["showButton"]);
      },
    );
  }

  _showButton() async{
    if (controller.webViewController != null) {
      if (await controller.webViewController!.getUrl() != null) {
        if (!(await controller.webViewController!.getUrl())!.toString().contains(RegExp(r"(m.so.com)|(quark.sm.cn)|(cn.bing.com)"))) {
          return true;
        }
      }
    }
    return false;
  }

  List<List<String>> getSites() {
    return [
      ["神马小说", "https://quark.sm.cn/s?q=&from=smor&safe=1"],
      ["360搜索", "https://m.so.com/s?q="],
      ["必应搜索", "https://cn.bing.com/search?q="],
    ];
  }
}
