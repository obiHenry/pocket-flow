import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exception.dart';
import '../../domain/entities/app_user.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  // AuthRemoteDataSourceImpl(super.firebaseService);
  @override
  Future<Either<AppException, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    return await register<AppUser>(
      email: email,
      password: password,
      parser: (credential) => AppUser.fromFirebaseUser(credential.user!),
    );
  }

  @override
  Future<Either<AppException, AppUser>> login({
    required String email,
    required String password,
  }) async {
    return await signIn<AppUser>(
      email: email,
      password: password,
      parser: (credential) => AppUser.fromFirebaseUser(credential.user!),
    );
  }

  @override
  Future<Either<AppException, Unit>> signOut() async {
    return await logout();
  }

  @override
  Future<Either<AppException, AppUser?>> getUser() async {
    return await getCurrentUser<AppUser?>(
      parser: (User? user) {
        return user != null ? AppUser.fromFirebaseUser(user) : null;
      },
    );
  }

  @override
  Future<Either<AppException, Unit>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    return await updateProfile(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<Either<AppException, Unit>> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    // setDocument is used instead of createDocument because we want the
    // Firestore doc ID to match the user's UID — makes all future lookups simple.
    return await setDocument(
      collection: 'users',
      docId: userId,
      data: {
        'uid': userId,
        'email': email,
        'displayName': displayName ?? '',
        'photoUrl': photoUrl ?? '',
        // serverTimestamp() writes the server's time, not the device's clock.
        // This avoids timezone/clock-skew issues across devices.
        'createdAt': FieldValue.serverTimestamp(),
        'currency': 'NGN',
        'plan': 'free',
        'balance': 0.0,
      },
    );
  }

  @override
  Future<Either<AppException, AppUser>> signinWithGoogle() async {
    return await signInWithGoogle<AppUser>(
      parser: (UserCredential credential) {
        final user = credential.user;
        if (user == null) {
          throw AppException('Google sign-in failed: No user found.');
        }
        return AppUser.fromFirebaseUser(user);
      },
    );
  }

  @override
  Future<Either<AppException, AppUser>> signinWithApple() async {
    return await signInWithApple<AppUser>(
      parser: (UserCredential credential) {
        final user = credential.user;
        if (user == null) {
          throw AppException('Apple sign-in failed: No user found.');
        }
        return AppUser.fromFirebaseUser(user);
      },
    );
  }

  @override
  Future<Either<AppException, Unit>> resetPassword({
    required String email,
  }) async {
    return await sendPasswordResetEmail(email: email);
  }

  @override
  Future<Either<AppException, bool>> checkEmailVerified() {
    // TODO: implement checkEmailVerified
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Unit>> verifyEmail() {
    // TODO: implement verifyEmail
    throw UnimplementedError();
  }
}
