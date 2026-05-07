import 'package:dio/dio.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Dio get client => _dio;
}
