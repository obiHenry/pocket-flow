import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, UserModel>> fetchCurrentUser() async {
    // Delegates straight to the datasource — no extra mapping needed
    // because the datasource already returns a UserModel.
    return await _remoteDataSource.fetchCurrentUser();
  }

  @override
  Future<Either<AppException, Unit>> updateUser(UserModel user) async {
    return await _remoteDataSource.updateUser(user);
  }

  @override
  Future<Either<AppException, Unit>> deleteUser(String userId) async {
    return await _remoteDataSource.deleteUser(userId);
  }

  @override
  Future<Either<AppException, Unit>> logOut() async {
    return await _remoteDataSource.logOut();
  }
}
