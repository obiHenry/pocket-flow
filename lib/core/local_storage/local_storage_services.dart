import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const _ratesKey = 'cached_exchange_rates';
  static const _timestampKey = 'rates_last_fetch';
  static const _onboardingKey = 'has_seen_onboarding';

  Future<void> saveOnboardingStatus() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<bool> getOnboardingStatus() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveRates(Map<String, double> rates) async {
    final String encodedData = jsonEncode(rates);
    await _prefs.setString(_ratesKey, encodedData);
    await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, double>> getRates() async {
    final String? cachedData = _prefs.getString(_ratesKey);
    if (cachedData != null) {
      final Map<String, dynamic> decodedMap = jsonDecode(cachedData);
      return decodedMap.map((key, value) => MapEntry(key, value.toDouble()));
    }
    return {};
  }

  DateTime? getLastFetchTime() {
    final int? timestamp = _prefs.getInt(_timestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> clearCache() async {
    await _prefs.remove(_ratesKey);
    await _prefs.remove(_timestampKey);
  }
}
