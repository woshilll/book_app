import 'dart:convert';

import 'package:book_app/model/result/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'dio_method.dart';

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
        // 请求基地址
        // baseUrl: "http://192.168.72.192:9898",
        baseUrl: "http://app.woshilll.top",
        // baseUrl: "http://192.168.31.237:9898",
        // 连接服务器超时时间，单位是毫秒
        connectTimeout: 60 * 1000,
        // 接收数据的最长时限
        receiveTimeout: 60 * 1000));
  }

  Future download(url, savePath, {Function(int, int)? onProgress, CancelToken? cancelToken}) async{
    return _dio?.download(url, savePath, onReceiveProgress: onProgress, cancelToken: cancelToken);
  }

  Future get<T>(
      {
        required String url,
        Map<String, dynamic>? params,
        bool showLoading = true
      }
      ) async {
    if (showLoading) {
      await EasyLoading.show(status: '加载中...', maskType: EasyLoadingMaskType.clear);
    }
    return await requestHttp(url, params: params);
  }

  /// Dio request 方法
  Future requestHttp<T>(String url,
      {DioMethod method = DioMethod.get,
      Map<String, dynamic>? params,
      bool isShowErrorToast = true,
      bool isAddTokenInHeader = true,
      FormData? formData,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.delete: 'delete',
      DioMethod.put: 'put'
    };

    try {
      Response response;

      /// 不同请求方法，不同的请求参数,按实际项目需求分.
      /// 这里 get 是 queryParameters，其它用 data. FormData 也是 data
      /// 注意: 只有 post 方法支持发送 FormData.
      switch (method) {
        case DioMethod.get:
          response = await _dio!.request(url,
              queryParameters: params,
              options: Options(method: methodValues[method], extra: {
                'isAddTokenInHeader': isAddTokenInHeader,
                'isShowErrorToast': isShowErrorToast
              }));
          break;
        default:
          // 如果有formData参数，说明是传文件，忽略params的参数
          if (formData != null) {
            response = await _dio!.post(url,
                data: formData,
                cancelToken: cancelToken,
                onSendProgress: onSendProgress,
                onReceiveProgress: onReceiveProgress);
          } else {
            response = await _dio!.request(url,
                data: params,
                cancelToken: cancelToken,
                options: Options(method: methodValues[method], extra: {
                  'isAddToken': isAddTokenInHeader,
                  'isShowErrorToast': isShowErrorToast
                }));
          }
      }
      await EasyLoading.dismiss();
      // json转model
      String jsonStr = json.encode(response.data);
      Map<String, dynamic> responseMap = json.decode(jsonStr);
      Result<T> result = Result.fromJson(responseMap, (T) => T);

      if (result.code != 200) {
        EasyLoading.showError(result.msg, duration: const Duration(seconds: 1));
      }
      return result.data;
    } on DioError catch (e) {
      EasyLoading.dismiss();
      // DioError是指返回值不为200的情况
      // 对错误进行判断
      onErrorInterceptor(e);
      // 判断是否断网了
    } catch (e) {
      // 其他一些意外的报错
    }
  }

// 错误判断
  void onErrorInterceptor(DioError err) {
    // 异常分类
    switch (err.type) {
      // 4xx 5xx response
      case DioErrorType.response:
        err.requestOptions.extra["errorMsg"] = err.response?.data ?? "连接异常";
        break;
      case DioErrorType.connectTimeout:
        err.requestOptions.extra["errorMsg"] = "连接超时";
        break;
      case DioErrorType.sendTimeout:
        err.requestOptions.extra["errorMsg"] = "发送超时";
        break;
      case DioErrorType.receiveTimeout:
        err.requestOptions.extra["errorMsg"] = "接收超时";
        break;
      case DioErrorType.cancel:
        err.requestOptions.extra["errorMsg"] =
            err.message.isNotEmpty ? err.message : "取消连接";
        break;
      case DioErrorType.other:
      default:
        err.requestOptions.extra["errorMsg"] = "连接异常";
        break;
    }
  }
}
