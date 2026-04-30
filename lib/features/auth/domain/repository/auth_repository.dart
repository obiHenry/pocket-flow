import 'package:dartz/dartz.dart';
import '../../../../core/error/exception.dart';
import '../entities/app_user.dart';

/// Abstract repository interface for authentication operations.
///
/// This defines the contract for all auth-related operations in the domain layer.
/// Implementations in the data layer will provide concrete implementations
/// using specific data sources (Firebase, REST API, etc.).
abstract class AuthRepository {
  Future<Either<AppException, AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<AppException, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<AppException, Unit>> logout();

  Future<Either<AppException, AppUser?>> getCurrentUser();

  Future<Either<AppException, Unit>> resetPassword({required String email});

  Future<Either<AppException, Unit>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  Future<Either<AppException, Unit>> verifyEmail();

  Future<Either<AppException, bool>> checkEmailVerified();

  Future<Either<AppException, AppUser>> signInWithGoogle();

  Future<Either<AppException, AppUser>> signInWithApple();

  Future<Either<AppException, AppUser>> signInWithFacebook();

  Future<Either<AppException, Unit>> deleteAccount();

  Future<Either<AppException, Unit>> reauthenticate({required String password});

  Future<Either<AppException, Unit>> updateEmail({required String newEmail});

  Future<Either<AppException, Unit>> updatePassword({
    required String newPassword,
  });

  Future<Either<AppException, AppUser>> linkEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<AppException, bool>> checkUserExists({required String email});

  Stream<AppUser?> watchAuthState();

  /// Creates the user's Firestore profile document after a successful signup.
  Future<Either<AppException, Unit>> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    // Default balance for new users
  });
}
