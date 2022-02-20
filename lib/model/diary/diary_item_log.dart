class DiaryItemLog{
  int? diaryItemId;
  String? name;
  String? content;
  String? updator;
  String? updateTime;
  int? version;

  DiaryItemLog({this.diaryItemId, this.name, this.content, this.updator, this.updateTime, this.version});

  factory DiaryItemLog.fromJson(Map<String, dynamic> json) => DiaryItemLog(
    diaryItemId: json["diaryItemId"],
    name: json["name"],
    content: json["content"],
    updator: json["updator"],
    updateTime: json["updateTime"],
    version: json["version"],
  );
}