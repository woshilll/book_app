
import 'dart:io';

class HttpManager {
  static HttpClient? _httpClient;

  factory HttpManager() => getInstance();

  static HttpManager get instance => getInstance();
  static HttpManager? _instance;

  static HttpManager getInstance() {
    _instance ??= HttpManager._init();

    return _instance!;
  }

  HttpManager._init() {
    _httpClient ??= HttpClient();
  }

  static HttpClient? get httpClient => _httpClient;
}
