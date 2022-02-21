import 'package:book_app/api/diary_api.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_controller.dart';
import 'package:book_app/module/diary/component/input_field.dart';
import 'package:book_app/module/diary/component/input_type.dart';
import 'package:book_app/util/input/input_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DiaryItemAddScreen extends GetView<DiaryItemAddController> {
  const DiaryItemAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 15, left: 20, right: 20),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "新建日记",
                        style: Theme.of(context).textTheme.headline2,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  InputField(
                    label: '日记本名',
                    initValue: controller.diaryItem.diaryName,
                    readable: true,
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
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InputField(
                    label: '内容',
                    inputType: InputType.richText,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: const Text("新增"),
                    onPressed: () async{
                      if (controller.formKey.currentState!.validate()) {
                        // Navigator.pop(context);
                      }
                    },

                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}