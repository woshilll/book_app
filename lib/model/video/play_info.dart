class PlayInfo{
  int? size;
  String? playURL;
  String? fps;
  String? height;
  String? width;
  String? definition;


  PlayInfo({this.size, this.playURL, this.fps, this.height, this.width,
    this.definition});

  factory PlayInfo.fromJson(Map<String, dynamic> json) => PlayInfo(
    size: json["size"],
    playURL: json["playURL"],
    fps: json["fps"],
    height: json["height"],
    width: json["width"],
    definition: json["definition"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'size': size,
    'playURL': playURL,
    'fps': fps,
    'height': height,
    'width': width,
    'definition': definition,
  };

  @override
  String toString() {
    return 'PlayInfo{size: $size, playURL: $playURL, fps: $fps, height: $height, width: $width, definition: $definition}';
  }
}
