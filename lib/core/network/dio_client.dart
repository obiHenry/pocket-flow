import 'package:dio/dio.dart';
import '../config/env/env_config.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.exchangeUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio));
    if (EnvConfig.instance.enableLogs) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
        ),
      );
    }
  }
}
