import 'package:flutter/material.dart';

/// 数值变化监听
class CounterNotify extends ChangeNotifier {
  int _count = 0;
  int get count => _count;


  addCount([int number = 1]) {
    _count += number;
    notifyListeners();
  }

  setCount(int number) {
    _count = number;
    notifyListeners();
  }

  resetCount() {
    _count = 0;
    notifyListeners();
  }
}