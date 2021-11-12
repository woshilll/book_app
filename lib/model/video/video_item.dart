class VideoItem{
  int? id;
  int? videoId;
  String? name;
  String? vid;
  int? sort;


  VideoItem({this.id, this.videoId, this.name, this.vid, this.sort});

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
    id: json["id"],
    name: json["name"],
    videoId: json["videoId"],
    vid: json["vid"],
    sort: json["sort"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'videoId': videoId,
    'vid': vid,
    'sort': sort,
  };
}
