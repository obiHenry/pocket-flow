// features/transactions/data/datasources/transaction_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/firebase/firebase_services.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource extends FirebaseService {
  Future<Either<AppException, String>> addTransaction(
    TransactionModel transaction,
    String userId,
  );

  Future<Either<AppException, Unit>> deleteTransaction(
    String transactionId,
    String userId,
  );

  Future<Either<AppException, Unit>> editTransaction(
    TransactionModel transaction,
    String userId,
  );

  Future<Either<AppException, List<TransactionModel>>> fetchTransactions(
    String userId,
  );

  Future<
    Either<
      AppException,
      ({List<TransactionModel> transactions, DocumentSnapshot? lastDoc})
    >
  >
  fetchTransactionsPaginated(
    String userId, {
    required int limit,
    DocumentSnapshot? startAfter,
  });
}

class TransactionRemoteDataSourceImpl extends TransactionRemoteDataSource {
  @override
  Future<Either<AppException, String>> addTransaction(
    TransactionModel transaction,
    String userId,
  ) async {
    // Step 1: Create the document — Firestore auto-generates the doc ID.
    final result = await createDocument<String>(
      collection: 'users/$userId/transactions',
      data: transaction.toFirebase(), // no 'id' field yet at this point
      parser: (docId) => docId,
    );

    // Step 2: Stamp the real Firestore ID back onto the document so that
    // fetchTransactions can later read it from data['id'].
    return result.fold((exception) => Left(exception), (docId) async {
      await updateDocument(
        collection: 'users/$userId/transactions',
        docId: docId,
        data: {'id': docId},
      );
      return Right(docId);
    });
  }

  @override
  Future<Either<AppException, Unit>> deleteTransaction(
    String transactionId,
    String userId,
  ) async {
    return await deleteDocument(
      collection: 'users/$userId/transactions',
      docId: transactionId,
    );
  }

  @override
  Future<Either<AppException, Unit>> editTransaction(
    TransactionModel transaction,
    String userId,
  ) async {
    return await updateDocument(
      collection: 'users/$userId/transactions',
      docId: transaction.id,
      data: transaction.toFirebase(),
    );
  }

  @override
  Future<Either<AppException, List<TransactionModel>>> fetchTransactions(
    String userId,
  ) async {
    return await fetchCollection<List<TransactionModel>>(
      collection: 'users/$userId/transactions',
      parser: (docs) => docs
          .map(
            (data) => TransactionModel.fromFirebase(data['id'] as String, data),
          )
          .toList(),
    );
  }

  @override
  Future<
    Either<
      AppException,
      ({List<TransactionModel> transactions, DocumentSnapshot? lastDoc})
    >
  >
  fetchTransactionsPaginated(
    String userId, {
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    final result = await fetchCollectionPaginated(
      collection: 'users/$userId/transactions',
      limit: limit,
      startAfter: startAfter,
    );
    return result.fold(
      (e) => Left(e),
      (page) => Right((
        transactions: page.docs
            .map(
              (data) =>
                  TransactionModel.fromFirebase(data['id'] as String, data),
            )
            .toList(),
        lastDoc: page.lastDoc,
      )),
    );
  }
}
