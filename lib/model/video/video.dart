class Video{
  int? id;
  String? name;
  String? description;
  String? coverImg;
  String? type;
  String? tagName;
  int? sort;
  String? actors;
  String? serial;
  String? releaseDay;
  double? score;
  String? coverImgBig;


  Video({this.id, this.name, this.description, this.coverImg, this.type,
    this.tagName, this.sort, this.actors, this.serial, this.releaseDay, this.score, this.coverImgBig});

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    coverImg: json["coverImg"],
    type: json["type"],
    tagName: json["tagName"],
    sort: json["sort"],
    actors: json["actors"],
    serial: json["serial"],
    releaseDay: json["releaseDay"],
    score: json["score"],
    coverImgBig: json["coverImgBig"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'coverImg': coverImg,
    'type': type,
    'tagName': tagName,
    'sort': sort,
    'actors': actors,
    'serial': serial,
    'releaseDay': releaseDay,
    'score': score,
    'coverImgBig': coverImgBig,
  };
}
