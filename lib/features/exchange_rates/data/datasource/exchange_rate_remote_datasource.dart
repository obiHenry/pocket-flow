// features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart
import 'package:dartz/dartz.dart';
import 'package:pocketflow/core/constants/api_contants.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/network/api_services.dart';
import '../models/exchange_rate_model.dart';

abstract class ExchangeRateRemoteDataSource extends ApiService {
  ExchangeRateRemoteDataSource(super.dio);

  Future<Either<AppException, ExchangeRateModel>> fetchLatestRates(
    String baseCurrency,
  );
}

class ExchangeRateRemoteDataSourceImpl extends ExchangeRateRemoteDataSource {
  ExchangeRateRemoteDataSourceImpl(super.dio);

  @override
  Future<Either<AppException, ExchangeRateModel>> fetchLatestRates(
    String baseCurrency,
  ) async {
    // Uses latest/{base} endpoint — returns all conversion_rates relative to base.
    // Since base is NGN, rates are "1 NGN = X foreign", so we invert to get
    // "1 foreign = Y NGN" (e.g. USD = 1580 NGN).
    return await get<ExchangeRateModel>(
      '${ApiContants.exchangeApiKey}/latest/$baseCurrency',
      parser: (json) {
        final raw = Map<String, dynamic>.from(json['conversion_rates'] as Map);
        final rates = <String, double>{};
        raw.forEach((key, value) {
          if (key != baseCurrency) {
            final v = (value as num).toDouble();
            rates[key] = v == 0 ? 0.0 : 1.0 / v;
          }
        });
        return ExchangeRateModel(base: baseCurrency, rates: rates);
      },
    );
  }
}
