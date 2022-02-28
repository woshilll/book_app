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
          margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${controller.isView ? '查看' : controller.isAdd ? '新建' : '修改'}日记本",
                      style: Theme.of(context).textTheme.headline2,
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                InputField(
                  label: '日记名',
                  initValue: controller.diary!.diaryName,
                  onDataChange: (value) {
                    controller.diary!.diaryName = value;
                  },
                  inputValidator: (value) {
                    return lengthValidator(value, 1, 100);
                  },
                  readable: controller.isView,
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '标签',
                  initValue: controller.diary!.diaryTag,
                  onDataChange: (value) {
                    controller.diary!.diaryTag = value;
                  },
                  inputValidator: (value) {
                    return lengthValidator(value, 1, 10);
                  },
                  readable: controller.isView,
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '写给谁',
                  initValue: controller.diary!.receiver,
                  textInputType: TextInputType.phone,
                  onDataChange: (value) {
                    controller.diary!.receiver = value;
                  },
                  readable: controller.isView,
                  inputType: InputType.phone,
                  inputValidator: phoneValidator,
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '你的邮箱',
                  textInputType: TextInputType.emailAddress,
                  initValue: controller.diary!.diarySetting?.creatorEmail,
                  onDataChange: (value) {
                    controller.diary!.diarySetting?.creatorEmail = value;
                  },
                  inputType: InputType.email,
                  inputValidator: emailValidator,
                  readable: controller.isView,
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '写给谁的邮箱',
                  textInputType: TextInputType.emailAddress,
                  initValue: controller.diary!.diarySetting?.receiverEmail,
                  onDataChange: (value) {
                    controller.diary!.diarySetting?.receiverEmail = value;
                  },
                  inputType: InputType.email,
                  inputValidator: emailValidator,
                  readable: controller.isView,
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
                            controller.diary!.diarySetting?.updateRemindCreator = value;
                          },
                          initValue: controller.diary!.diarySetting?.updateRemindCreator,
                          readable: controller.isView,
                          inputType: InputType.radio,
                        )),
                    SizedBox(
                        width: 165,
                        child: InputField(
                          label: '提醒写给谁',
                          initValue: controller.diary!.diarySetting?.updateRemindReceiver,
                          onDataChange: (value) {
                            controller.diary!.diarySetting?.updateRemindReceiver = value;
                          },
                          readable: controller.isView,
                          inputType: InputType.radio,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  label: '写给谁可编辑',
                  initValue: controller.diary!.diarySetting?.receiverCanUpdate,
                  onDataChange: (value) {
                    controller.diary!.diarySetting?.receiverCanUpdate = value;
                  },
                  readable: controller.isView,
                  inputType: InputType.radio,
                ),
                const SizedBox(
                  height: 20,
                ),
                if (!controller.isView)
                ElevatedButton(
                  child: Text(controller.isAdd ? "新增" : "修改"),
                  onPressed: () async{
                    if (controller.formKey.currentState!.validate()) {
                      await controller.saveOrUpdate(context);
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