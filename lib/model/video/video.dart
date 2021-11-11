class Video{
  int? id;
  String? name;
  String? description;
  String? coverImg;
  String? type;
  String? tagName;
  int? sort;


  Video({this.id, this.name, this.description, this.coverImg, this.type,
    this.tagName, this.sort});

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    coverImg: json["coverImg"],
    type: json["type"],
    tagName: json["tagName"],
    sort: json["sort"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'coverImg': coverImg,
    'type': type,
    'tagName': tagName,
    'sort': sort,
  };
}
