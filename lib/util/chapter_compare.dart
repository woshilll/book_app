import 'package:book_app/model/chapter/chapter.dart';

List<Chapter> chapterCompare(List<Chapter> oldList, List<Chapter> newList) {
  List<Chapter> remainList = [];
  Set<Chapter> set = {};
  set.addAll(oldList);
  for (var element in newList) {
    if (set.add(element)) {
      remainList.add(element);
    }
  }
  return remainList;
}