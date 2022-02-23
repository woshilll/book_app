import 'dart:convert';

class DiaryItemVo{
  bool? isMe;
  String? diaryName;
  String? diaryTag;
  int? diaryId;
  String? fromWho;
  String? toWho;
  bool? canUpdate;
  int? diaryItemId;
  String? diaryItemName;
  String? diaryItemCreateTime;
  String? diaryItemContent;
  int? diaryItemVersion;

  DiaryItemVo({this.isMe, this.diaryName, this.diaryTag, this.diaryId, this.fromWho, this.canUpdate, this.diaryItemId, this.diaryItemName, this.diaryItemVersion, this.diaryItemCreateTime, this.toWho, this.diaryItemContent});

  factory DiaryItemVo.fromJson(Map<String, dynamic> json) => DiaryItemVo(
    isMe: json["isMe"],
    diaryName: json["diaryName"],
    diaryTag: json["diaryTag"],
    diaryId: json["diaryId"],
    fromWho: json["fromWho"],
    canUpdate: json["canUpdate"],
    diaryItemId: json["diaryItemId"],
    diaryItemName: json["diaryItemName"],
    diaryItemVersion: json["diaryItemVersion"],
    diaryItemCreateTime: json["diaryItemCreateTime"],
    toWho: json["toWho"],
    diaryItemContent: json["diaryItemContent"],
  );
  static List<DiaryItemVo> fromJsonList(json) {
    List<DiaryItemVo> res = [];
    for (var date in jsonDecode(json)) {
      res.add(DiaryItemVo.fromJson(date));
    }
    return res;
  }
}