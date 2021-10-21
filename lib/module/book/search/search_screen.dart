import 'package:book_app/module/book/search/serach_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'component/content_paint.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      body: CustomPaint(
        painter: ContentPaint(),
      ),
    );
  }

}
