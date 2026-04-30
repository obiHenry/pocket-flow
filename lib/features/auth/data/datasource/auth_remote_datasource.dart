import 'package:dartz/dartz.dart';
import 'package:pocketflow/core/firebase/firebase_services.dart';

import '../../../../core/error/exception.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource extends FirebaseService {
  Future<Either<AppException, AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<AppException, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<AppException, Unit>> signOut();

  Future<Either<AppException, AppUser?>> getUser();

  Future<Either<AppException, Unit>> resetPassword({required String email});

  Future<Either<AppException, Unit>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  @override
  Future<Either<AppException, Unit>> verifyEmail();

  Future<Either<AppException, AppUser>> signinWithGoogle();
  Future<Either<AppException, AppUser>> signinWithApple();

  @override
  Future<Either<AppException, bool>> checkEmailVerified();

  /// Creates the user's profile document in Firestore after signup.
  /// Uses setDocument so the doc ID matches the user's UID for easy lookup.
  Future<Either<AppException, Unit>> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  });
}
