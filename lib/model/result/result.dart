import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';
@JsonSerializable(genericArgumentFactories: true)
class Result<T> {
  int code;
  String msg;
  T data;


  Result(this.code, this.msg, this.data);


  factory Result.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) => _$ResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => _$ResultToJson(this, toJsonT);
  @override
  String toString() {
    return 'Result{code: $code, msg: $msg, data: $data}';
  }
}