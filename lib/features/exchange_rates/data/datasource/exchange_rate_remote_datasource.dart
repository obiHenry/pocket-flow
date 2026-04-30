// features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart
import 'package:dartz/dartz.dart';
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
    return await get<ExchangeRateModel>(
      '/latest', // Example endpoint path
      queryParameters: {'from': 'USD', 'to': baseCurrency},
      parser: (json) => ExchangeRateModel.fromJson(json),
    );
  }
}
