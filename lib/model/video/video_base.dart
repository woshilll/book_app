class VideoBase{
  String? videoId;
  String? coverURL;
  String? title;
  String? duration;


  VideoBase({this.videoId, this.coverURL, this.title, this.duration});

  factory VideoBase.fromJson(Map<String, dynamic> json) => VideoBase(
    videoId: json["videoId"],
    coverURL: json["coverURL"],
    title: json["title"],
    duration: json["duration"],
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'videoId': videoId,
    'coverURL': coverURL,
    'title': title,
    'duration': duration,
  };

  @override
  String toString() {
    return 'VideoBase{videoId: $videoId, coverURL: $coverURL, title: $title, duration: $duration}';
  }
}
