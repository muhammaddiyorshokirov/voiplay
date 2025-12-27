import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    final options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio = Dio(options);

    // Cache interceptor for GET requests
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
      // keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    // Logging
    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    // Add authorization interceptor placeholder (to be set by AuthService)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // If Authorization header is already set, leave it.
          return handler.next(options);
        },
      ),
    );
  }
}
