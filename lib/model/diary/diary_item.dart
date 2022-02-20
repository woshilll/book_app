class DiaryItem{
  int? id;
  int? diaryId;
  String? name;
  String? content;
  String? createTime;
  int? version;

  DiaryItem({this.id, this.diaryId, this.name, this.content, this.createTime, this.version});

  factory DiaryItem.fromJson(Map<String, dynamic> json) => DiaryItem(
    id: json["id"],
    diaryId: json["diaryId"],
    name: json["name"],
    content: json["content"],
    createTime: json["createTime"],
    version: json["version"],
  );
  Map<String, dynamic> toJson() => <String, dynamic>{
    "id": id,
    "diaryId": diaryId,
    "name": name,
    "content": content,
    "createTime": createTime,
    "version": version,
  };
}