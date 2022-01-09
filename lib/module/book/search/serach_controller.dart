import 'dart:async';

import 'package:book_app/api/book_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/search/search_history.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchController extends GetxController {
  late BuildContext context = globalContext;
  /// 文本焦点
  FocusNode searchNode = FocusNode();
  /// 文本控制器
  TextEditingController searchTextController = TextEditingController();
  /// 历史记录
  List<SearchHistory> histories = [];
  /// 站点列表
  List<SearchHistory> sites = SearchHistory.defaultList();
  String site = "";
  FloatingSearchBarController searchBarController = FloatingSearchBarController();
  var searchText = "";
  @override
  Future<void> onInit() async {
    super.onInit();
    await initData();
  }

  initData() async {
    // 获取历史记录
    histories = SearchHistory.fromList(SaveUtil.getModelList(Constant.searchHistoryKey));


  }

  @override
  void onReady() async{
    super.onReady();
    // 获取站点列表
    // sites = await BookApi.getSites();
    // if (sites.isNotEmpty && sites[0].site != null) {
    //   site = sites[0].site!;
    // }
    update(["sites"]);
  }
  @override
  void onClose() {
    super.onClose();
    searchTextController.dispose();
    SaveUtil.setModelList(Constant.searchHistoryKey, histories);
  }

  /// 搜索
  void search(str, String? site) {
    site ??= this.site;
    if (str.isEmpty) {
      return;
    }
    // 增加搜索历史
    if (histories.length >= 10) {
      // 移除最后一个
      histories.removeAt(histories.length - 1);
    }
    // 找到搜索过该词的, 并删除
    histories.removeWhere((element) => element.label == str);
    histories.insert(0, SearchHistory(label: str, site: site));
    update(["history"]);
    Get.toNamed(Routes.searchValue, arguments: {"site": SearchHistory(label: str, site: site)})!.then((value) {
      searchTextController.text = "";
    });
  }

  /// 删除历史
  void removeHistory(int index) {
    histories.removeAt(index);
    update(["history"]);
  }

  /// 设置站点
  void setSite(site) {
    if (this.site != site) {
      this.site = site;
      update(["sites"]);
    }
  }

  void toSearch(siteIndex) {
    Get.offAndToNamed(Routes.searchValue, arguments: {"keyword": "$searchText 小说", "site": sites[siteIndex].site, "siteIndex": siteIndex, "sites": sites});
  }

  void pop() {
    Get.back();
  }


}
