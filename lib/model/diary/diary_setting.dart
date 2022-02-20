class DiarySetting{
  int? diaryId;
  String? receiverEmail;
  String? creatorEmail;
  String? updateRemindReceiver;
  String? updateRemindCreator;
  String? receiverCanUpdate;

  DiarySetting({this.diaryId, this.receiverEmail, this.creatorEmail, this.updateRemindReceiver, this.updateRemindCreator, this.receiverCanUpdate});

  factory DiarySetting.fromJson(Map<String, dynamic> json) => DiarySetting(
    diaryId: json["diaryId"],
    receiverEmail: json["receiverEmail"],
    creatorEmail: json["creatorEmail"],
    updateRemindReceiver: json["updateRemindReceiver"],
    updateRemindCreator: json["updateRemindCreator"],
    receiverCanUpdate: json["receiverCanUpdate"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    "diaryId": diaryId,
    "receiverEmail": receiverEmail,
    "creatorEmail": creatorEmail,
    "updateRemindReceiver": updateRemindReceiver,
    "updateRemindCreator": updateRemindCreator,
    "receiverCanUpdate": receiverCanUpdate,
  };

  @override
  String toString() {
    return 'DiarySetting{diaryId: $diaryId, receiverEmail: $receiverEmail, creatorEmail: $creatorEmail, updateRemindReceiver: $updateRemindReceiver, updateRemindCreator: $updateRemindCreator, receiverCanUpdate: $receiverCanUpdate}';
  }
}