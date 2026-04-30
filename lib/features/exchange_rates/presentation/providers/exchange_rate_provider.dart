import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_provider.dart';
import '../../data/datasource/exchange_rate_remote_datasource.dart';
import '../../data/repository/exchange_rate_repository_impl.dart';
import 'exchange_rate_notifier.dart';

final exchangeRateDataSourceProvider = Provider<ExchangeRateRemoteDataSource>(
  (ref) => ExchangeRateRemoteDataSourceImpl(ref.watch(dioProvider)),
);

/// Provides the repository — depends on the datasource above.
final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>(
  (ref) => ExchangeRateRepositoryImpl(ref.read(exchangeRateDataSourceProvider)),
);
final exchangeRateProvider =
    AsyncNotifierProvider<ExchangeRateNotifier, Map<String, double>>(() {
      return ExchangeRateNotifier();
    });
