import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../error/exception.dart';

// Moved from AuthApiService: Helper extension to get the raw string value for the enum

/// Abstract base class for all API services.
/// It provides generic methods for making HTTP requests (GET, POST, PUT, DELETE)
/// and handles common error mapping using ApiException.
abstract class ApiService {
  final Dio _dio;

  ApiService(this._dio); // Constructor takes the Dio instance

  /// Generic method to perform an HTTP request.
  /// [method]: The HTTP method (e.g., 'GET', 'POST', 'PUT', 'DELETE').
  /// [path]: The endpoint path (e.g., '/users', '/auth/login').
  /// [data]: The request body for POST/PUT methods.
  /// [queryParameters]: Query parameters for the request.
  /// [options]: Additional Dio options for this specific request.
  /// [parser]: A function to parse the successful response data into the desired model type.
  Future<Either<AppException, T>> request<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required T Function(dynamic json) parser,
  }) async {
    try {
      // Create final Options. If `options` is provided, use it.
      // Otherwise, create a new Options object using the provided `method`.
      // The Dio `request` method will correctly interpret the method from `options`.
      final finalOptions = options ?? Options(method: method);

      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: finalOptions,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      // Check for successful HTTP status codes (2xx range)
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return Right(parser(response.data));
      } else {
        // This block is a fallback for unusual cases where a non-2xx status
        // might not be caught by DioExceptionType.badResponse.
        return Left(
          UnknownException(
            'Request failed with status: ${response.statusCode}',
            code: response.statusCode.toString(),
          ),
        );
      }
    } on DioException catch (e) {
      // Catch Dio-specific errors and convert them to your custom AppException hierarchy
      return Left(AppException.fromDioException(e));
    }

    // catch (e) {
    //   // Catch any other unexpected errors that are not DioExceptions
    //   return Left(
    //     UnknownException('An unexpected error occurred: ${e.toString()}'),
    //   );
    // }
  }

  /// Convenience method for making GET requests.
  ///
  /// [path]: The endpoint path.
  /// [queryParameters]: Optional query parameters.
  /// [options]: Optional custom Dio [Options].
  /// [parser]: Function to parse the response.
  Future<Either<AppException, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic json) parser,
    ProgressCallback? onReceiveProgress,
  }) {
    // Ensure the method is 'GET' while preserving other options from the caller.
    final finalOptions = (options ?? Options()).copyWith(method: 'GET');

    return request<T>(
      'GET', // This parameter is for the `request` method's `method` argument (fallback if options is null)
      path,
      queryParameters: queryParameters,
      options: finalOptions, // Use the options that guarantee the method is GET
      parser: parser,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Convenience method for making POST requests.
  ///
  /// [path]: The endpoint path.
  /// [data]: The request body.
  /// [options]: Optional custom Dio [Options].
  /// [parser]: Function to parse the response.
  Future<Either<AppException, T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
    required T Function(dynamic json) parser,
    ProgressCallback? onSendProgress,
  }) {
    // Ensure the method is 'POST' while preserving other options from the caller.
    final finalOptions = (options ?? Options()).copyWith(method: 'POST');

    return request<T>(
      'POST', // This parameter is for the `request` method's `method` argument (fallback if options is null)
      path,
      data: data,
      options:
          finalOptions, // Use the options that guarantee the method is POST
      parser: parser,
      onSendProgress: onSendProgress,
    );
  }

  /// Convenience method for making PATCH requests.
  ///
  /// [path]: The endpoint path.
  /// [data]: The request body.
  /// [options]: Optional custom Dio [Options].
  /// [parser]: Function to parse the response.
  Future<Either<AppException, T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
    required T Function(dynamic json) parser,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    // Ensure the method is 'PUT' while preserving other options from the caller.
    final finalOptions = (options ?? Options()).copyWith(method: 'PATCH');

    return request<T>(
      'PATCH', // This parameter is for the `request` method's `method` argument (fallback if options is null)
      path,
      data: data,
      options: finalOptions, // Use the options that guarantee the method is PUT
      parser: parser,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Convenience method for making PUT requests.
  ///
  /// [path]: The endpoint path.
  /// [data]: The request body.
  /// [options]: Optional custom Dio [Options].
  /// [parser]: Function to parse the response.
  Future<Either<AppException, T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
    required T Function(dynamic json) parser,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    // Ensure the method is 'PUT' while preserving other options from the caller.
    final finalOptions = (options ?? Options()).copyWith(method: 'PUT');

    return request<T>(
      'PUT',
      path,
      data: data,
      options: finalOptions,
      parser: parser,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Convenience method for making DELETE requests.
  ///
  /// [path]: The endpoint path.
  /// [data]: The request body (optional for DELETE, but possible).
  /// [queryParameters]: Optional query parameters.
  /// [options]: Optional custom Dio [Options].
  /// [parser]: Function to parse the response.
  Future<Either<AppException, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic json) parser,
  }) {
    // Ensure the method is 'DELETE' while preserving other options from the caller.
    final finalOptions = (options ?? Options()).copyWith(method: 'DELETE');

    return request<T>(
      'DELETE', // This parameter is for the `request` method's `method` argument (fallback if options is null)
      path,
      data: data,
      queryParameters: queryParameters,
      options:
          finalOptions, // Use the options that guarantee the method is DELETE
      parser: parser,
    );
  }

  /// [file]: The file to be uploaded.
  /// [reason]: The purpose of the file upload (e.g., STORE_LOGO, USER_PROFILE_PHOTO).
  /// [fileName]: Optional. The name of the file. If null, a name will be derived from the file path.
  /// [onSendProgress]: Callback for tracking upload progress.
  ///
  /// Returns an [Either] containing the parsed response data on success,
  /// or an [AppException] on failure.
  // Future<Either<AppException, T>> upload<T>({
  //   required String path,
  //   required File file,
  //   required FileUploadReason reason,
  //   required T Function(dynamic json) parser,
  //   String? fileName, // Optional file name
  //   ProgressCallback? onSendProgress, // For upload progress tracking
  // }) async {
  //   String fileExtension = file.path.split('.').last;
  //   String finalFileName =
  //       fileName ??
  //       'file_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

  //   FormData formData = FormData.fromMap({
  //     "file": await MultipartFile.fromFile(
  //       file.path,
  //       filename: finalFileName,
  //       contentType: MediaType.parse(
  //         getMimeType(file.path),
  //       ), // Optional: if you want to specify content type
  //     ),
  //     "reason": reason.rawValue, // Use the raw string value from the enum
  //     if (fileName != null) "fileName": fileName, // Only add if provided
  //   });

  //   return request<T>(
  //     'POST', // Explicitly specifying the method
  //     path,
  //     data: formData,
  //     options: Options(
  //       method: 'POST',
  //       headers: {Headers.contentTypeHeader: 'multipart/form-data'},
  //     ),
  //     parser: parser,
  //     onSendProgress: onSendProgress,
  //   );
  // }

  String getMimeType(String path) {
    if (path.contains('.')) {
      final extension = path.split('.').last;
      switch (extension) {
        case 'jpg':
          return 'image/jpeg';
        case 'jpeg':
          return 'image/jpeg';
        case 'png':
          return 'image/png';
        case 'pdf':
          return 'application/pdf';
        case 'doc':
          return 'application/msword';
        case 'docx':
          return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        case 'xls':
          return 'application/vnd.ms-excel';
        case 'xlsx':
          return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        case 'ppt':
          return 'application/vnd.ms-powerpoint';
        case 'pptx':
          return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        default:
          return 'application/octet-stream';
      }
    }
    return 'application/octet-stream';
  }
}
