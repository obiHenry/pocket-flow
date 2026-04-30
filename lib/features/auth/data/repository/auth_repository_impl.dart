import 'package:dartz/dartz.dart';
import '../../../../core/error/exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    return _remoteDataSource.signUp(email: email, password: password);
  }

  @override
  Future<Either<AppException, AppUser>> login({
    required String email,
    required String password,
  }) async {
    return _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<Either<AppException, Unit>> logout() async {
    return _remoteDataSource.logout();
  }

  @override
  Future<Either<AppException, AppUser?>> getCurrentUser() async {
    return _remoteDataSource.getUser();
  }

  @override
  Future<Either<AppException, Unit>> resetPassword({
    required String email,
  }) async {
    // If you have this in your datasource
    return _remoteDataSource.resetPassword(email: email);
  }

  @override
  Future<Either<AppException, Unit>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    return _remoteDataSource.updateUserProfile(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<Either<AppException, AppUser>> signInWithGoogle() async {
    return await _remoteDataSource.signinWithGoogle();
  }

  @override
  Future<Either<AppException, AppUser>> signInWithApple() async {
    return await _remoteDataSource.signinWithApple();
  }

  @override
  Future<Either<AppException, Unit>> verifyEmail() async {
    // If you have this in your datasource
    return _remoteDataSource.verifyEmail();
  }

  @override
  Future<Either<AppException, bool>> checkEmailVerified() async {
    // If you have this in your datasource
    return _remoteDataSource.checkEmailVerified();
  }

  @override
  Future<Either<AppException, bool>> checkUserExists({required String email}) {
    // TODO: implement checkUserExists
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Unit>> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, AppUser>> linkEmailPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement linkEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Unit>> reauthenticate({
    required String password,
  }) {
    // TODO: implement reauthenticate
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, AppUser>> signInWithFacebook() {
    // TODO: implement signInWithFacebook
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Unit>> updateEmail({required String newEmail}) {
    // TODO: implement updateEmail
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Unit>> updatePassword({
    required String newPassword,
  }) {
    // TODO: implement updatePassword
    throw UnimplementedError();
  }

  @override
  Stream<AppUser?> watchAuthState() {
    // TODO: implement watchAuthState
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Unit>> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    return _remoteDataSource.createUserProfile(
      userId: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
