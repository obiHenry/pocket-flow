// features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exception.dart';
import '../datasource/exchange_rate_remote_datasource.dart';
import '../models/exchange_rate_model.dart';

abstract class ExchangeRateRepository {
  Future<Either<AppException, ExchangeRateModel>> getLatestRates({
    required String base,
  });
}

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateRemoteDataSource _remoteDataSource;
  // Note: You would also inject your LocalStorageService here for the Phase 5 caching logic

  ExchangeRateRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, ExchangeRateModel>> getLatestRates({
    required String base,
  }) async {
    // Phase 5 Logic: You could check local cache here first.
    // For now, we hit the remote source.
    return await _remoteDataSource.fetchLatestRates(base);
  }
}
