import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 2),
  });

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    var requestOptions = err.requestOptions;

    // Only retry if it's a network error or a timeout
    bool shouldRetry =
        err.type != DioExceptionType.cancel &&
        err.type != DioExceptionType.badResponse &&
        requestOptions.extra['retryCount'] != maxRetries;

    if (shouldRetry) {
      int retryCount = (requestOptions.extra['retryCount'] ?? 0) + 1;
      requestOptions.extra['retryCount'] = retryCount;

      // Wait before retrying
      await Future.delayed(retryInterval * retryCount);

      // Re-run the request
      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    return super.onError(err, handler);
  }
}
