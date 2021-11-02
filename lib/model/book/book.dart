import 'package:book_app/model/base.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:json_annotation/json_annotation.dart';
part 'book.g.dart';

@JsonSerializable()
class Book extends Base{
  int? id;
  String? name;
  String? description;
  String? author;
  String? indexImg;
  int? curChapter;
  int? curPage;
  String? url;
  int? type;
  List<Chapter>? chapters;

  Book({this.id, this.name, this.description, this.author, this.indexImg,
    this.curChapter, this.curPage, this.url, this.type = 1, this.chapters});

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
    'author': author,
    'indexImg': indexImg,
    'curChapter': curChapter,
    'curPage': curPage,
    'url': url,
    'type': type,
  };

  @override
  String toString() {
    return 'Book{id: $id, name: $name, description: $description, author: $author, indexImg: $indexImg, curChapter: $curChapter, curPage: $curPage, url: $url, type: $type}';
  }
}
