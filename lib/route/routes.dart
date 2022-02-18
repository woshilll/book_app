/// 路由路径页
abstract class Routes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';


  /// 小说
  static const bookHome = '/book/home';
  static const read = '/book/read';
  static const readSetting = '/book/read/setting';
  static const readMoreSetting = '/book/read/moreSetting';
  static const search = '/book/search';
  static const searchValue = '/book/search/value';
  static const searchValueView = '/book/search/value/view';

  /// 设置
  static const settingHome = '/setting/home';



  /// 电影
  static const movieHome = '/movie/home';
  static const movieInfo = '/movie/info';

  /// 日记
  static const diaryHome = '/diary/home';

  static String getRouteName(String? route) {
    switch(route) {
      case bookHome:
        return "小说";
      case movieHome:
        return "电影";
      default:
        return "默认";
    }
  }
}
