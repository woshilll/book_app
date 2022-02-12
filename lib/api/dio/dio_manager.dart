import 'dart:convert';

import 'package:book_app/exception/common_exception.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/decrypt_util.dart';
import 'package:book_app/util/encrypt_util.dart';
import 'package:book_app/util/save_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gt;

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
        // baseUrl: "http://app.woshilll.top",
        baseUrl: "http://192.168.31.236:9898",
        // 连接服务器超时时间，单位是毫秒
        connectTimeout: 60 * 1000,
        // 接收数据的最长时限
        receiveTimeout: 60 * 1000,
    ));
  }

  Future download(url, savePath, {Function(int, int)? onProgress, CancelToken? cancelToken}) async{
    return await _dio?.download(url, savePath, onReceiveProgress: onProgress, cancelToken: cancelToken);
  }

  Future<dynamic> get(
      {
        required String url,
        Map<String, dynamic>? params,
        bool showLoading = true,
        Map<String, dynamic>? headers,
      }
      ) async {
    if (showLoading) {
      await EasyLoading.show(status: '加载中...', maskType: EasyLoadingMaskType.clear);
    }
    return await requestHttp(url, params: params, encrypt: false);
  }

  Future<dynamic> post(
      {
        required String url,
        Map<String, dynamic>? params,
        Map<String, dynamic>? body,
        FormData? formData,
        bool showLoading = true,
        Map<String, dynamic>? headers,
        bool encrypt = false
      }
      ) async {
    if (showLoading) {
      await EasyLoading.show(status: '加载中...', maskType: EasyLoadingMaskType.clear);
    }
    return await requestHttp(url, params: params, method: DioMethod.post, headers: headers, formData: formData, body: body, encrypt: encrypt);
  }

  Future<dynamic> put(
      {
        required String url,
        Map<String, dynamic>? params,
        Map<String, dynamic>? body,
        FormData? formData,
        bool showLoading = true,
        Map<String, dynamic>? headers,
        bool encrypt = false
      }
      ) async {
    if (showLoading) {
      await EasyLoading.show(status: '加载中...', maskType: EasyLoadingMaskType.clear);
    }
    return await requestHttp(url, params: params, method: DioMethod.put, headers: headers, formData: formData, body: body, encrypt: encrypt);
  }

  Future<dynamic> delete(
      {
        required String url,
        Map<String, dynamic>? params,
        Map<String, dynamic>? body,
        FormData? formData,
        bool showLoading = true,
        Map<String, dynamic>? headers,
        bool encrypt = false
      }
      ) async {
    if (showLoading) {
      await EasyLoading.show(status: '加载中...', maskType: EasyLoadingMaskType.clear);
    }
    return await requestHttp(url, params: params, method: DioMethod.delete, headers: headers, formData: formData, body: body, encrypt: encrypt);
  }

  /// Dio request 方法
  Future<dynamic> requestHttp(String url,
      {DioMethod method = DioMethod.get,
      Map<String, dynamic>? params,
      Map<String, dynamic>? body,
      Map<String, dynamic>? headers,
      FormData? formData,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      bool encrypt = false,
      ProgressCallback? onReceiveProgress}) async {
    const methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.delete: 'delete',
      DioMethod.put: 'put'
    };

    try {
      SaveUtil.setString(Constant.initRoute, "/home");
      Log.i("发起请求 $url");
      String? token = SaveUtil.getString(Constant.token);
      if (token != null) {
        token = token.replaceAll("\"", "");
      }
      Response response;

      if (encrypt) {
        // 是加密
        var encryptData = await EncryptUtil.encryptData(body);
        body = {
          "encryptData": encryptData[0],
          "encryptAes": encryptData[1]
        };
      }

      /// 不同请求方法，不同的请求参数,按实际项目需求分.
      /// 这里 get 是 queryParameters，其它用 data. FormData 也是 data
      /// 注意: 只有 post 方法支持发送 FormData.
      switch (method) {
        case DioMethod.get:
          response = await _dio!.request(url,
              queryParameters: params,
              options: Options(method: methodValues[method], headers: {"token": token}));
          break;
        default:
          // 如果有formData参数，说明是传文件，忽略params的参数
          if (formData != null) {
            response = await _dio!.post(url,
                data: formData,
                queryParameters: params,
                cancelToken: cancelToken,
                onSendProgress: onSendProgress,
                onReceiveProgress: onReceiveProgress);
          } else {
            response = await _dio!.request(url,
                data: body,
                queryParameters: params,
                cancelToken: cancelToken,
                options: Options(method: methodValues[method], headers: {"token": token}));
          }
      }
      await EasyLoading.dismiss();
      // json转model
      String jsonStr = json.encode(response.data);
      Map<String, dynamic> responseMap = json.decode(jsonStr);
      Log.i("接收到服务器数据：$responseMap");
      if (responseMap["code"] != 200) {
        if (responseMap["code"] == 401) {
          if (gt.Get.currentRoute == Routes.home) {
            await gt.Get.toNamed(Routes.login);
          } else {
            await gt.Get.offAndToNamed(Routes.login, arguments: {"route": gt.Get.currentRoute});
          }
          SaveUtil.remove(Constant.token);
          throw CommonException("未登录");
        } else {
          throw CommonException(responseMap["msg"]);
        }
      }
      dynamic data = responseMap["data"];
      if (responseMap["encrypt"]) {
        // 加密数据
        return DecryptUtil.decryptAes(DecryptUtil.getAes(data["encryptAes"]), data["data"]);
      }
      return data;
    } on DioError catch (e) {
      EasyLoading.dismiss();
      // DioError是指返回值不为200的情况
      // 对错误进行判断
      onErrorInterceptor(e);
      throw "";
      // 判断是否断网了
    } on CommonException catch (e) {
      EasyLoading.showError(e.message);
      throw "";
    } catch (e) {
      // 其他一些意外的报错
      throw "";
    }
  }

// 错误判断
  void onErrorInterceptor(DioError err) {
    // 异常分类
    String msg;
    switch (err.type) {
      // 4xx 5xx response
      case DioErrorType.response:
        msg = err.response?.data ?? "连接异常";
        break;
      case DioErrorType.connectTimeout:
        msg = "连接超时";
        break;
      case DioErrorType.sendTimeout:
        msg = "发送超时";
        break;
      case DioErrorType.receiveTimeout:
        msg = "接收超时";
        break;
      case DioErrorType.cancel:
        msg =
            err.message.isNotEmpty ? err.message : "取消连接";
        break;
      case DioErrorType.other:
      default:
        msg = "连接异常";
        break;
    }
    EasyLoading.showError(msg);
  }
}
