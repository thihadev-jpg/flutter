

import 'package:dio/dio.dart';

abstract class ApiService {
  // factory ApiService(Dio dio,{String? baseUrl})
}

class ApiServiceProvider{
  static ApiService? _instance;


}