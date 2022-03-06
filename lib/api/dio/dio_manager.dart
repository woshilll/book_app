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
    _dio ??= Dio(BaseOptions(
        baseUrl: "http://localhost:9898",
        // 连接服务器超时时间，单位是毫秒
        connectTimeout: 60 * 1000,
        // 接收数据的最长时限
        receiveTimeout: 60 * 1000,
    ));
  }

  Future download(url, savePath, {Function(int, int)? onProgress, CancelToken? cancelToken}) async{
    return await _dio?.download(url, savePath, onReceiveProgress: onProgress, cancelToken: cancelToken);
  }
}
