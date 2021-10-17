// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      id: json['id'] as int?,
      bookId: json['bookId'] as int?,
      name: json['name'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'name': instance.name,
      'content': instance.content,
      'url': instance.url,
    };
