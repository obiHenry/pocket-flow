// features/transactions/data/repositories/transaction_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exception.dart';
import '../datasource/transaction_datasource.dart';
import '../models/transaction_model.dart';

abstract class TransactionRepository {
  Future<Either<AppException, TransactionModel>> addTransaction(
    TransactionModel transaction,
  );

  Future<Either<AppException, Unit>> deleteTransaction(String transactionId);

  Future<Either<AppException, Unit>> editTransaction(
    TransactionModel transaction,
  );

  Future<Either<AppException, List<TransactionModel>>> fetchTransactions();

  Future<
    Either<
      AppException,
      ({List<TransactionModel> transactions, DocumentSnapshot? lastDoc})
    >
  >
  fetchTransactionsPaginated({required int limit, DocumentSnapshot? startAfter});
}

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;
  TransactionRepositoryImpl(this._remoteDataSource);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Either<AppException, String> get _resolvedUserId {
    final uid = _userId;
    if (uid == null) {
      return Left(AppException('User not logged in.'));
    }
    return Right(uid);
  }

  @override
  Future<Either<AppException, TransactionModel>> addTransaction(
    TransactionModel transaction,
  ) async {
    return _resolvedUserId.fold(
      (e) async => Left(e),
      (userId) async {
        final txWithUser = transaction.copyWith(userId: userId);
        final result = await _remoteDataSource.addTransaction(txWithUser, userId);
        return result.fold(
          (exception) => Left(exception),
          (docId) => Right(txWithUser.copyWith(id: docId)),
        );
      },
    );
  }

  @override
  Future<Either<AppException, Unit>> deleteTransaction(
    String transactionId,
  ) async {
    return _resolvedUserId.fold(
      (e) async => Left(e),
      (userId) async =>
          await _remoteDataSource.deleteTransaction(transactionId, userId),
    );
  }

  @override
  Future<Either<AppException, Unit>> editTransaction(
    TransactionModel transaction,
  ) async {
    return _resolvedUserId.fold(
      (e) async => Left(e),
      (userId) async =>
          await _remoteDataSource.editTransaction(transaction, userId),
    );
  }

  @override
  Future<Either<AppException, List<TransactionModel>>> fetchTransactions() async {
    return _resolvedUserId.fold(
      (e) async => Left(e),
      (userId) async => await _remoteDataSource.fetchTransactions(userId),
    );
  }

  @override
  Future<
    Either<
      AppException,
      ({List<TransactionModel> transactions, DocumentSnapshot? lastDoc})
    >
  >
  fetchTransactionsPaginated({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    return _resolvedUserId.fold(
      (e) async => Left(e),
      (userId) async => await _remoteDataSource.fetchTransactionsPaginated(
        userId,
        limit: limit,
        startAfter: startAfter,
      ),
    );
  }
}
