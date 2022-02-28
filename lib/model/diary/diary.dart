import 'dart:convert';

import 'package:book_app/model/diary/diary_setting.dart';

class Diary{
  int? id;
  String? creator;
  String? receiver;
  String? diaryName;
  String? diaryTag;
  String? createTime;
  String? updateTime;
  DiarySetting? diarySetting;

  Diary({this.id, this.creator, this.diaryName, this.receiver, this.diaryTag, this.createTime, this.updateTime, this.diarySetting});

  factory Diary.fromJson(json) {
    return Diary(
        id: json["id"],
        creator: json["creator"],
        receiver: json["receiver"],
        diaryName: json["diaryName"],
        diaryTag: json["diaryTag"],
        createTime: json["createTime"],
        updateTime: json["updateTime"],
        diarySetting: json["diarySetting"] == null ? null : DiarySetting.fromJson(json["diarySetting"])
    );
  }

  factory Diary.fromJsonStr(jsonStr) {
    var json = jsonDecode(jsonStr);
    return Diary(
        id: json["id"],
        creator: json["creator"],
        receiver: json["receiver"],
        diaryName: json["diaryName"],
        diaryTag: json["diaryTag"],
        createTime: json["createTime"],
        updateTime: json["updateTime"],
        diarySetting: json["diarySetting"] == null ? null : DiarySetting.fromJson(json["diarySetting"])
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    "id": id,
    "creator": creator,
    "receiver": receiver,
    "diaryName": diaryName,
    "diaryTag": diaryTag,
    "createTime": createTime,
    "updateTime": updateTime,
    "diarySetting": diarySetting?.toJson()
  };

  @override
  String toString() {
    return 'Diary{id: $id, creator: $creator, receiver: $receiver, diaryName: $diaryName, diaryTag: $diaryTag, createTime: $createTime, updateTime: $updateTime, diarySetting: $diarySetting}';
  }

  static List<Diary> fromJsonList(json) {
    List<Diary> res = [];
    for (var date in jsonDecode(json)) {
      res.add(Diary.fromJson(date));
    }
    return res;
  }
}