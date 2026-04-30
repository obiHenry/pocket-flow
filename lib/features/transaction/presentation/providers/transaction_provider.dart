import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import 'transaction_notifier.dart';

import '../../data/datasource/transaction_datasource.dart';
import '../../data/repository/transaction_repository.dart';

/// Provides the datasource — one instance shared across the app.
final transactionDataSourceProvider = Provider<TransactionRemoteDataSource>(
  (_) => TransactionRemoteDataSourceImpl(),
);

/// Provides the repository — depends on the datasource above.
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(ref.read(transactionDataSourceProvider)),
);

final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      () => TransactionNotifier(),
    );
