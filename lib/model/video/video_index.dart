import 'package:book_app/model/video/video.dart';

class VideoIndex{
 List<Video>? carouselList;

 List<Video>? movieList;

 List<Video>? tvList;

 List<Video>? hotList;


 VideoIndex({this.carouselList, this.movieList, this.tvList, this.hotList});

  factory VideoIndex.fromJson(Map<String, dynamic> json) {
    List<Video>? carouselList = [];
    for (var data in json["carouselList"]) {
      carouselList.add(Video.fromJson(data));
    }

    List<Video>? movieList = [];
    for (var data in json["movieList"]) {
      movieList.add(Video.fromJson(data));
    }

    List<Video>? tvList = [];
    for (var data in json["tvList"]) {
      tvList.add(Video.fromJson(data));
    }

    List<Video>? hotList = [];
    for (var data in json["hotList"]) {
      hotList.add(Video.fromJson(data));
    }

    return VideoIndex(carouselList: carouselList, movieList: movieList, tvList: tvList, hotList: hotList);
  }

  static VideoIndex defaultValue() {
    return VideoIndex(carouselList: [], movieList: [], tvList: [], hotList: []);
  }
}
