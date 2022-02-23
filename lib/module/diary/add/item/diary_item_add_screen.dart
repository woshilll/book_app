import 'dart:convert';

import 'package:book_app/api/diary_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_controller.dart';
import 'package:book_app/module/diary/component/edit/rich_text_edit_screen.dart';
import 'package:book_app/module/diary/component/input_field.dart';
import 'package:book_app/module/diary/component/input_type.dart';
import 'package:book_app/util/input/input_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';


class DiaryItemAddScreen extends GetView<DiaryItemAddController>{
  const DiaryItemAddScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    controller.context = context;
    var size = MediaQuery.of(context);
    double height = size.size.height - 100;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  height: height,
                  margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            "新建日记",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        InputField(
                          label: '日记本名',
                          initValue: controller.diaryItem.diaryName,
                          readable: true,
                          focusNode: controller.diaryNameFocusNode,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InputField(
                          label: '名称',
                          onDataChange: (value) {
                            controller.diaryItem.name = value;
                          },
                          inputValidator: (value) {
                            return lengthValidator(value, 1, 100);
                          },
                          focusNode: controller.diaryItemNameFocusNode,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "内容",
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                  child: RichTextEditScreen(controller.richTextFocusNode, controller.quillController,)
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          child: Card(
                            elevation: 5,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              width: MediaQuery.of(context).size.width - 100,
                              child: const Text("新增", style: TextStyle(fontSize: 20, height: 1),),
                            ),
                          ),
                          onTap: () async{
                            if (controller.formKey.currentState!.validate()) {
                              if (controller.quillController.document.length <= 1) {
                                EasyLoading.showToast("请输入内容");
                              }
                              controller.diaryItem.content = jsonEncode(controller.quillController.document.toDelta().toJson());
                              await DiaryApi.addDiaryItem(controller.diaryItem);
                              Navigator.pop(context);
                            }
                          },
                          onLongPress: () {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  controller.unFocus();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}