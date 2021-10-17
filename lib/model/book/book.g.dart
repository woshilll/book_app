// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      author: json['author'] as String?,
      indexImg: json['indexImg'] as String?,
      curChapter: json['curChapter'] as int?,
      curPage: json['curPage'] as int?,
      url: json['url'] as String?,
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'author': instance.author,
      'indexImg': instance.indexImg,
      'curChapter': instance.curChapter,
      'curPage': instance.curPage,
      'url': instance.url,
      'chapters': instance.chapters,
    };
