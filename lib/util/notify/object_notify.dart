import 'package:flutter/material.dart';

/// 对象变化监听
class ObjectNotify<T> extends ChangeNotifier {
  late T _data;
  T get data => _data;

  ObjectNotify(T data) {
    _data = data;
  }

  update(T data) {
    _data = data;
    notifyListeners();
  }
}