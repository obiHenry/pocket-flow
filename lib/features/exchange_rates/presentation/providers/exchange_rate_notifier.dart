import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/features/exchange_rates/presentation/providers/exchange_rate_provider.dart';

import '../../../../main.dart';

class ExchangeRateNotifier extends AsyncNotifier<Map<String, double>> {
  @override
  FutureOr<Map<String, double>> build() async {
    return _fetchRates();
  }

  Future<Map<String, double>> _fetchRates() async {
    // 1. Try to get from Local Storage first
    final cachedData = ref.read(localStorageProvider).getRates();
    final lastFetch = ref.read(localStorageProvider).getLastFetchTime();

    // 2. If cache exists and is fresh (less than 60 mins), use it
    if (cachedData != null && lastFetch != null) {
      final diff = DateTime.now().difference(lastFetch);
      if (diff.inMinutes < 60) return cachedData;
    }

    // 3. Otherwise, fetch from API (Dio)
    final result = await ref
        .read(exchangeRateRepositoryProvider)
        .getLatestRates(base: 'NGN');

    return result.fold(
      (error) {
        print('Error fetching exchange rates: $error');
        return cachedData ?? {}; // Fallback to old cache if API fails
      },
      (r) {
        // Save to cache for next time
        ref.read(localStorageProvider).saveRates(r.rates);
        return r.rates;
      },
    );
  }
}
