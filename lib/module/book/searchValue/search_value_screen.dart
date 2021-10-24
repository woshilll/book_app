import 'package:book_app/module/book/searchValue/search_value_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchValueScreen extends GetView<SearchValueController> {
  const SearchValueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SearchValueController>(
        id: "result",
        builder: (controller) {
          return ListView.separated(
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(top: 15),
                padding: EdgeInsets.only(left: 10, right: 10),
                child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      controller.buildRichText(controller.searchResults[index].label, 20, FontWeight.bold),
                      controller.buildRichText(controller.searchResults[index].description, 15, FontWeight.normal),
                    ],
                  ),
                  onTap: () {
                    Get.toNamed(Routes.searchValueView, arguments: {"url": controller.searchResults[index].url});
                  },
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 1,
                margin: EdgeInsets.only(top: 15),
                color: Colors.grey,
              );
            },
          );
        },
      ),
    );
  }

}