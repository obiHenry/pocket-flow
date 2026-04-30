import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  factory AppException.fromFirebaseAuth(dynamic e) {
    if (e is FirebaseAuthException) {
      final message = switch (e.code) {
        'network-request-failed' =>
          'No internet connection. Check your network and try again.',
        'user-not-found' => 'No account found with this email.',
        'wrong-password' => 'Incorrect password.',
        'email-already-in-use' => 'An account with this email already exists.',
        'weak-password' => 'Password is too weak.',
        'invalid-email' => 'Invalid email address.',
        'user-disabled' => 'This account has been disabled.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        _ => e.message ?? 'Authentication error.',
      };
      return AppException(message, code: e.code);
    }
    if (e is AppException) return e;
    return AppException(e.toString());
  }

  factory AppException.fromFirestore(dynamic e) {
    if (e is FirebaseException) {
      final message = switch (e.code) {
        'unavailable' =>
          'No internet connection. Check your network and try again.',
        'permission-denied' => 'You do not have permission to do this.',
        'not-found' => 'The requested data was not found.',
        'already-exists' => 'This record already exists.',
        'deadline-exceeded' =>
          'Request timed out. Check your connection and try again.',
        _ => e.message ?? 'Database error.',
      };
      return AppException(message, code: e.code);
    }
    if (e is AppException) return e;
    return AppException(e.toString());
  }

  factory AppException.fromStorage(dynamic e) {
    if (e is FirebaseException) {
      final message = switch (e.code) {
        'object-not-found' => 'File not found.',
        'unauthorized' => 'You do not have permission to access this file.',
        'retry-limit-exceeded' =>
          'Upload failed. Check your connection and try again.',
        'canceled' => 'Upload was cancelled.',
        _ => e.message ?? 'Storage error.',
      };
      return AppException(message, code: e.code);
    }
    if (e is AppException) return e;
    return AppException(e.toString());
  }

  factory AppException.fromUnknown(dynamic e) {
    if (e is AppException) return e;
    return AppException(e.toString());
  }

  factory AppException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType
          .connectionError: // Formerly DioExceptionType.other when connection problems
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'No Internet.',
          code: dioException.response?.statusCode.toString(),
        );
      case DioExceptionType.badResponse: // HTTP status code is not 2xx
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;
        String errorMessage = 'An unexpected error occurred.';
        // Attempt to extract specific error message from API response
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData is String && responseData.isNotEmpty) {
          errorMessage = responseData;
        } else if (responseData is Map && responseData.containsKey('errors')) {
          errorMessage = responseData['errors'][0]['message'];
        }

        switch (statusCode) {
          case 400:
            return BadRequestException(
              errorMessage,
              code: statusCode.toString(),
            );
          case 401:
            return UnauthorizedException(
              errorMessage,
              code: statusCode.toString(),
            );
          case 422:
            return ValidationException(
              errorMessage,
              code: statusCode.toString(),
            );
          case 403:
            return ForbiddenException(
              errorMessage,
              code: statusCode.toString(),
            );
          case 404:
            return NotFoundException(errorMessage, code: statusCode.toString());
          case 409:
            return ConflictException(errorMessage, code: statusCode.toString());
          case 422: // Unprocessable Entity
            return ValidationException(
              errorMessage,
              code: statusCode.toString(),
            );
          case 500:
            return ServerException(errorMessage, code: statusCode.toString());
          default:
            return UnknownException(errorMessage, code: statusCode.toString());
        }
      case DioExceptionType.cancel:
        return RequestCancelledException(
          'Request to API server was cancelled.',
          code: dioException.response?.statusCode.toString(),
        );
      case DioExceptionType.badCertificate:
        return UnauthorizedException(
          'Bad certificate, connection not secure.',
          code: dioException.response?.statusCode.toString(),
        );
      default:
        // This handles DioExceptionType.unknown and other unforeseen types
        return UnknownException(
          'An unknown error occurred: ${dioException.message}',
          code: dioException.response?.statusCode.toString(),
        );
    }
  }

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class BadRequestException extends AppException {
  BadRequestException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.code});
}

class ForbiddenException extends AppException {
  ForbiddenException(super.message, {super.code});
}

class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code});
}

class ConflictException extends AppException {
  ConflictException(super.message, {super.code});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

class RequestCancelledException extends AppException {
  RequestCancelledException(super.message, {super.code});
}

class UnknownException extends AppException {
  UnknownException(super.message, {super.code});
}
