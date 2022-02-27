import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/diary/diary.dart';
import 'package:book_app/model/diary/diary_item.dart';
import 'package:book_app/model/diary/diary_item_vo.dart';
import 'package:book_app/model/video/aliyun_play_info.dart';
import 'package:book_app/model/video/video_index.dart';
import 'package:book_app/model/video/video_info.dart';
import 'package:book_app/util/rsa_util.dart';

class DiaryApi {
  /// 获取每天的日记列表 yyyy-MM-dd
  static Future<List<DiaryItemVo>> getDiaryItemListByDate(String date) async{
    return DiaryItemVo.fromJsonList(await DioManager.instance.get(url: "/app/diaryItem/list/$date", showLoading: true, params: RsaUtil.getPublicParams()));
  }

  /// 获取日记本列表
  static Future<List<Diary>> getDiaryList() async{
    return Diary.fromJsonList(await DioManager.instance.get(url: "/app/diary/list", showLoading: true, params: RsaUtil.getPublicParams()));
  }

  /// 新增日记本
  static Future<void> addDiary(Diary diary) async{
    await DioManager.instance.post(url: "/app/diary", showLoading: true, body: diary.toJson(), encrypt: true);
  }


  /// 新增日记内容
  static Future<void> addDiaryItem(DiaryItem diaryItem) async{
    await DioManager.instance.post(url: "/app/diaryItem", showLoading: true, body: diaryItem.toJson(), encrypt: true);
  }

  /// 更新日记内容
  static Future<void> updateDiaryItem(DiaryItem diaryItem) async{
    await DioManager.instance.put(url: "/app/diaryItem", showLoading: true, body: diaryItem.toJson(), encrypt: true);
  }

  /// 查看日记内容
  static Future<String> diaryItemContent(diaryItemId) async{
    return await DioManager.instance.get(url: "/app/diaryItem/$diaryItemId", showLoading: true, params: RsaUtil.getPublicParams());
  }

}
