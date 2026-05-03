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

// No autoDispose: transactions are shared by the home tab (recent list) and the
// transactions tab (full paginated list). Disposing on tab switch would discard
// the pagination cursor, the in-memory offline queue, and the local cache
// written during the session — forcing a cold Firestore fetch on every return.
final transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      () => TransactionNotifier(),
    );
