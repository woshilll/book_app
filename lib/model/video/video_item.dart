class VideoItem{
  int? id;
  int? videoId;
  String? name;
  String? vid;
  int? sort;
  String? subtitle;


  VideoItem({this.id, this.videoId, this.name, this.vid, this.sort, this.subtitle});

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
    id: json["id"],
    name: json["name"],
    videoId: json["videoId"],
    vid: json["vid"],
    sort: json["sort"],
    subtitle: json["subtitle"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'videoId': videoId,
    'vid': vid,
    'sort': sort,
    'subtitle': subtitle,
  };
}
