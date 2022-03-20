import 'package:book_app/module/book/searchValue/search_value_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

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
            SizedBox(
              height: 56,
              child: GetBuilder<SearchValueController>(
                id: "siteBar",
                builder: (controller) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: controller.sites.map<Widget>((e) {
                      int index = controller.sites.indexOf(e);
                      return GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(e[0], style: TextStyle(color: index == controller.siteIndex ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyText1!.color),),
                        ),
                        onTap: () {
                          if (controller.siteIndex != index) {
                            controller.siteIndex = index;
                            controller.webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(controller.sites[index][1])));
                            controller.update(["siteBar"]);
                          }

                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 30,
              // padding: const EdgeInsets.only(left: 15, right: 15),
              child: Marquee(
                text: "有关小说搜索 - 1.建议关键字后加(笔趣阁) 2.在你点击的网站里建议选择有\"目录\"、\"电脑\"字样的网站进行解析,也可直接在含有全部章节的页面进行解析",
                style: TextStyle(color: hexToColor("#E6A23C"), height: 1),
                blankSpace: 20.0,
              ),
            ),
            GetBuilder<SearchValueController>(
              id: "loadProcess",
              builder: (controller) {
                if (!controller.showLoadProcess) {
                  return Container();
                }
                return LinearProgressIndicator(
                  value: controller.loadProcess,
                  minHeight: 3,
                );
              },
            ),
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
                  child: const Icon(Icons.analytics, size: 30,),
                ),
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(const CircleBorder()),
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)
                ),
                onPressed: () async{
                  await controller.parse();
                },
                onLongPress: () {
                  EasyLoading.showToast("解析小说");
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
      initialUrlRequest: URLRequest(url: Uri.parse(controller.sites[controller.siteIndex][1])),
      onWebViewCreated: (webController) {
        controller.webViewController = webController;
      },
      onLoadStop: (x, y) async{
        controller.showParseButton = await _showButton();
        controller.showLoadProcess = false;
        controller.update(["showButton", "loadProcess"]);
      },
      onProgressChanged: (x, y) {
        controller.loadProcess = y / 100;
        controller.update(["loadProcess"]);
      },
      onLoadStart: (x, y) {
        controller.showLoadProcess = true;
        controller.loadProcess = 0;
        controller.update(["loadProcess"]);
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


}
