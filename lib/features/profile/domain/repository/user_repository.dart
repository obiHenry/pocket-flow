import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../data/models/user_model.dart';

/// Defines what user-related operations are available to the app.
/// The presentation layer depends on this interface, NOT the concrete implementation.
abstract class UserRepository {
  Future<Either<AppException, UserModel>> fetchCurrentUser();
  Future<Either<AppException, Unit>> updateUser(UserModel user);
  Future<Either<AppException, Unit>> deleteUser(String userId);
  Future<Either<AppException, Unit>> logOut();
}
