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
