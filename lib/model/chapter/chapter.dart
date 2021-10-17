import 'package:book_app/model/base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chapter.g.dart';
@JsonSerializable()
class Chapter extends Base{
  int? id;
  int? bookId;
  String? name;
  String? content;
  String? url;

  Chapter({this.id, this.bookId, this.name, this.content, this.url});

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChapterToJson(this);

  @override
  String toString() {
    return 'Chapter{id: $id, bookId: $bookId, name: $name, content: $content, url: $url}';
  }
}