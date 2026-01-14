import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project_configuration/config/env_config.dart';
import 'package:flutter_project_configuration/service/hive_service.dart';

class DioConfig {
  DioConfig._();
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }


  static Dio _createDio(){
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,

      headers: {
        'Accept': 'application/json',
      }
    );
    dio.interceptors.addAll([
      _LogInterceptor(),
    ]);
    return dio;
  }
  static void reset(){
    _dio = null;
  }
}

class _LogInterceptor extends Interceptor{

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async{
    await HiveService.init();
    // final token = HiveService.keys.token.get();
    dynamic token = '';
    if(token != null && token.isNotEmpty){
      options.headers['Authorization'] = 'Bearer $token';
    }
    if(kDebugMode){
      print('🚀 REQUEST[${options.method}] => PATH:${options.path}');
      print('HEADER: ${options.headers}');
      if(options.data != null){
        print('DATA: ${options.data}');
      }
      if(options.queryParameters.isNotEmpty){
        print('Query Parameters: ${options.queryParameters}');
      }
      super.onRequest(options, handler);
    }
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if(kDebugMode){
      print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('DATA: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if(kDebugMode){
      print('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print('Message: ${err.message}');
      print('Response: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

class _AuthInterceptor extends Interceptor{
  bool _isRefreshing = false;
  List<_PendingRequest> _pendingRequestList = [];
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if(err.response?.statusCode == 401){
      if(err.requestOptions.path.contains('SignIn Endpoint')){
        super.onError(err, handler);
        return;
      }

      if(_isRefreshing){
        _pendingRequestList.add(_PendingRequest(options: err.requestOptions, handler: handler));
        return;
      }
      _isRefreshing = true;
    }
    super.onError(err, handler);
  }
}

class _PendingRequest{
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest({required this.options,required this.handler});
}