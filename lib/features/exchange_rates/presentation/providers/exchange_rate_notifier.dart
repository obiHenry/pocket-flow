import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/features/exchange_rates/presentation/providers/exchange_rate_provider.dart';

import '../../../../core/local_storage/local_storage_provider.dart';

class ExchangeRateNotifier extends AsyncNotifier<Map<String, double>> {
  @override
  FutureOr<Map<String, double>> build() async {
    return _fetchRates();
  }

  Future<Map<String, double>> _fetchRates() async {
    final storage = ref.read(localStorageProvider);
    final cachedData = await storage.getRates();
    final lastFetch = storage.getLastFetchTime();

    if (cachedData.isNotEmpty && lastFetch != null) {
      final diff = DateTime.now().difference(lastFetch);
      if (diff.inMinutes < 60) return cachedData;
    }

    // Skip the API call entirely when offline
    final connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      return cachedData.isNotEmpty ? cachedData : {};
    }

    final result = await ref
        .read(exchangeRateRepositoryProvider)
        .getLatestRates(base: 'NGN');

    return result.fold(
      (error) => cachedData.isNotEmpty ? cachedData : {},
      (r) {
        storage.saveRates(r.rates);
        return r.rates;
      },
    );
  }
}
