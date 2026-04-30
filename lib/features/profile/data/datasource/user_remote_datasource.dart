import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/firebase/firebase_services.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource extends FirebaseService {
  /// Fetches the currently signed-in user's profile from Firestore.
  /// Named fetchCurrentUser to avoid conflict with FirebaseService.getCurrentUser.
  Future<Either<AppException, UserModel>> fetchCurrentUser();

  /// Writes updated user fields to Firestore (does NOT touch Firebase Auth).
  Future<Either<AppException, Unit>> updateUser(UserModel user);

  /// Deletes the user's Firestore document AND their Firebase Auth account.
  Future<Either<AppException, Unit>> deleteUser(String userId);

  /// Signs the user out of Firebase Auth.
  Future<Either<AppException, Unit>> logOut();
}

class UserRemoteDataSourceImpl extends UserRemoteDataSource {
  @override
  Future<Either<AppException, UserModel>> fetchCurrentUser() async {
    // Step 1: Get the UID from the currently signed-in Firebase Auth user.
    final authResult = await getCurrentUser<String?>(
      parser: (user) => user?.uid,
    );

    // fold lets us handle Left (error) and Right (uid) cleanly.
    return authResult.fold((exception) => Left(exception), (uid) async {
      if (uid == null) {
        return Left(AppException('No authenticated user found'));
      }
      // Step 2: Use the UID to fetch the user profile document from Firestore.
      return await getDocumentById<UserModel>(
        collection: 'users',
        docId: uid,
        parser: (data) {
          if (data == null) throw AppException('User profile not found');
          return UserModel.fromMap(data, uid);
        },
      );
    });
  }

  @override
  Future<Either<AppException, Unit>> updateUser(UserModel user) async {
    final uid = user.uid;
    if (uid == null) return Left(AppException('User ID is missing'));
    return await updateDocument(
      collection: 'users',
      docId: uid,
      data: user.toMap(),
    );
  }

  @override
  Future<Either<AppException, Unit>> deleteUser(String userId) async {
    // Step 1: Delete the Firestore profile document first.
    final firestoreResult = await deleteDocument(
      collection: 'users',
      docId: userId,
    );

    // If Firestore deletion failed, stop here — do not delete the Auth account.
    return firestoreResult.fold((exception) => Left(exception), (_) async {
      // Step 2: Delete the Firebase Auth account.
      return await deleteAccount();
    });
  }

  @override
  Future<Either<AppException, Unit>> logOut() async {
    return await logout();
  }
}
