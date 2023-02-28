import 'dart:isolate';

import 'package:book_app/log/log.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/message.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/toast.dart';

class ParseNetworkBook {
  String url;
  String? name;
  final SendPort sendPort;
  Isolate? _isolate;

  ParseNetworkBook(this.url, this.sendPort, {this.name});

  Future<List<dynamic>> parseInBackground() async{
    final p = ReceivePort();
    _isolate = await Isolate.spawn(_parse, p.sendPort,);
    return await p.first;
  }

  kill() {
    final _isolate = this._isolate;
    if (_isolate != null) {
      _isolate.kill();
    }
  }

  _parse(SendPort p) async{
    try {
      String? img;
      var results = (await HtmlParseUtil.parseChapter(url, img: (imgUrl) {
        img = imgUrl;
      },
          pageFunc: (page) {
            sendPort.send(Message(MessageType.parseNetworkBook, page));
          },
          name: (_bookName) {
            name = name ?? _bookName;
          }));
      url = results[0];
      var chapters = results[1];
      final Book book = Book(url: url, name: name, indexImg: img);
      var day = DateTime.now();
      book.updateTime = "${day.year}-${day.month}-${day.day}";
      return Isolate.exit(p, [book, chapters]);
    } catch (err) {
      Log.e(err);
      return Isolate.exit(p, []);
    }
  }
}