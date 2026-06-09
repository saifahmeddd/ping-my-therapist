import 'package:dio/dio.dart';

/// Factory for a configured [Dio] instance (interceptors can be added later).
abstract final class ApiClient {
  static Dio create({required String baseUrl}) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: const {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }
}
