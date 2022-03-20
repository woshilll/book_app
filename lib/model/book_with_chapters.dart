import 'dart:async';

import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';

class BookWithChapters {
  /// 书
  final Book _book;
  /// 章节
  final List<Chapter> _chapters;
  /// 已下载章节
  final List<Chapter> _downloadChapters = [];
  /// 通知
  Timer? _downloadTimer;
  /// 下载完成
  bool _downloadComplete = false;
  /// 是否中断
  bool _interruptDownload = false;
  BookWithChapters(this._book, this._chapters);

  /// 下载过程回调
  /// 书-已下载数-总数-是否完成
  void downloadCallback(Function(Book, int, int, bool) downloadCallback) {
    if (complete) {
      downloadCallback(_book, _downloadChapters.length, _chapters.length, _downloadComplete);
      _downloadTimer?.cancel();
      return;
    }
    _downloadTimer?.cancel();
    _downloadTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      downloadCallback(_book, _downloadChapters.length, _chapters.length, _downloadComplete);
    });
  }

  void dispose() {
    _downloadTimer?.cancel();
  }

  void downloadChaptersAdd(Chapter chapter) {
    _downloadChapters.add(chapter);
  }

  /// 下载完成
  void downloadComplete(bool complete) {
    _downloadComplete = complete;
  }

  /// 中断
  void interrupt() {
    dispose();
    _interruptDownload = true;
  }

  bool get complete => _downloadComplete;

  Book get book => _book;

  List<Chapter> get chapters => _chapters;

  bool get interruptDownload => _interruptDownload;
}