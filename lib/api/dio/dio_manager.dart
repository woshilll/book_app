import 'package:dio/dio.dart';

class DioManager {
  static Dio? _dio;

  factory DioManager() => getInstance();

  static DioManager get instance => getInstance();
  static DioManager? _instance;

  static DioManager getInstance() {
    _instance ??= DioManager._init();

    return _instance!;
  }

  DioManager._init() {
    _dio ??= Dio();
  }

  Future download(url, savePath, {Function(int, int)? onProgress, CancelToken? cancelToken}) async{
    return await _dio?.download(url, savePath, onReceiveProgress: onProgress, cancelToken: cancelToken);
  }

  static Dio? get dio => _dio;
}
