import 'package:book_app/api/diary_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/module/diary/add/diary/diary_add_controller.dart';
import 'package:book_app/module/diary/component/input_type.dart';
import 'package:book_app/util/input/input_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/input_field.dart';

class DiaryAddScreen extends GetView<DiaryAddController> {
  const DiaryAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      "新建日记本",
                      style: Theme.of(context).textTheme.headline2,
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                InputField(
                  label: '日记名',
                  onDataChange: (value) {
                    controller.diary.diaryName = value;
                  },
                  inputValidator: (value) {
                    return lengthValidator(value, 1, 100);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '标签',
                  onDataChange: (value) {
                    controller.diary.diaryTag = value;
                  },
                  inputValidator: (value) {
                    return lengthValidator(value, 1, 10);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '写给谁',
                  textInputType: TextInputType.phone,
                  onDataChange: (value) {
                    controller.diary.receiver = value;
                  },
                  inputType: InputType.phone,
                  inputValidator: phoneValidator,
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '你的邮箱',
                  textInputType: TextInputType.emailAddress,
                  onDataChange: (value) {
                    controller.diary.diarySetting?.creatorEmail = value;
                  },
                  inputType: InputType.email,
                  inputValidator: emailValidator,
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '写给谁的邮箱',
                  textInputType: TextInputType.emailAddress,
                  onDataChange: (value) {
                    controller.diary.diarySetting?.receiverEmail = value;
                  },
                  inputType: InputType.email,
                  inputValidator: emailValidator,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 165,
                        child: InputField(
                          label: '提醒自己',
                          onDataChange: (value) {
                            controller.diary.diarySetting?.updateRemindCreator = value;
                          },
                          inputType: InputType.radio,
                        )),
                    SizedBox(
                        width: 165,
                        child: InputField(
                          label: '提醒写给谁',
                          onDataChange: (value) {
                            controller.diary.diarySetting?.updateRemindReceiver = value;
                          },
                          inputType: InputType.radio,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '写给谁可编辑',
                  onDataChange: (value) {
                    controller.diary.diarySetting?.receiverCanUpdate = value;
                  },
                  inputType: InputType.radio,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text("新增"),
                  onPressed: () async{
                    if (controller.formKey.currentState!.validate()) {
                      await DiaryApi.addDiary(controller.diary);
                      Navigator.pop(context);
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
    );
  }

}