import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/search/serach_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class SearchScreen extends GetView<SearchController> {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 0,
        titleSpacing: 0,
        toolbarHeight: 44,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _bar(),
      ),
      body: _body(),
    );
  }

  Widget _bar() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 15),
          child: _selectSite(),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(left: 5, right: 10),
            height: 35,
            alignment: Alignment.centerLeft,
            child: TextField(
              maxLines: 1,
              focusNode: controller.searchNode,
              controller: controller.searchTextController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  hintText: "小说",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 28,),
                  fillColor: Colors.grey[300],
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.transparent
                    ),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent
                      ),
                      borderRadius: BorderRadius.circular(16)
                  ),
                  disabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent
                      ),
                      borderRadius: BorderRadius.circular(16)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent
                      ),
                      borderRadius: BorderRadius.circular(16)
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true
              ),
              onSubmitted: (str) {
                controller.search(str, null);
              },

            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        TextButton(
          child: const Text("取消", style: TextStyle(fontSize: 15),),
          onPressed: () {
            controller.searchNode.unfocus();
            Timer(const Duration(milliseconds: 100), () => Get.back());
          },
        )
      ],
    );
  }

  Widget _body() {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        height: double.infinity,
        width: double.infinity,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: const Text("搜索历史", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: GetBuilder<SearchController>(
                id: "history",
                builder: (controller) {
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(controller.histories.length, (index) {
                      return RawChip(
                        label: Text("${controller.histories[index].label}"),
                        deleteIcon: const Icon(Icons.close),
                        deleteIconColor: Colors.blue,
                        onDeleted: () {
                          controller.removeHistory(index);
                        },
                        onPressed: () {
                          controller.search(controller.histories[index].label, controller.histories[index].site);
                        },
                      );
                    }
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
      onTap: () {
        controller.searchNode.unfocus();
      },
    );
  }

  Widget _selectSite() {
    return GetBuilder<SearchController>(
      id: "sites",
      builder: (controller) {
        return DropdownButton(
          value: controller.site,
          iconSize: 0,
          underline: Container(height: 0,),
          hint: const Text("选择站点"),
          items: List.generate(controller.sites.length, (index) {
            return DropdownMenuItem(
              child: SizedBox(
                width: 60,
                child: Text("${controller.sites[index].label}", overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),),
              ),
              value: controller.sites[index].site,
            );
          }),
          onChanged: (value) {
            controller.setSite(value);
          },
        );
      },
    );
  }
}
