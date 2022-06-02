import 'dart:io';

import 'package:book_app/log/log.dart';
import 'package:book_app/util/html_parse_util.dart';

void main() async{
  for (int i = 0; i < 10; i++) {
    var client = HttpClient();
    var request = await client.getUrl(Uri.parse("https://m.xbiquke.net/59_59579/21330674.html"));
    var res = await request.close();
    List<List<int>> dataBytes = await res.toList();
    Log.i(i);
  }
}
