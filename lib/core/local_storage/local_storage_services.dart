import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const _ratesKey = 'cached_exchange_rates';
  static const _timestampKey = 'rates_last_fetch';
  static const _onboardingKey = 'has_seen_onboarding';
  static const _themeKey = 'theme_mode';

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }

  ThemeMode getThemeMode() {
    final value = _prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

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

  // --- Transaction cache ---

  static const _txCachePrefix = 'cached_tx_';

  Future<void> cacheTransactionsRaw(String uid, String json) async {
    await _prefs.setString('$_txCachePrefix$uid', json);
  }

  String? getCachedTransactionsRaw(String uid) {
    return _prefs.getString('$_txCachePrefix$uid');
  }

  // --- User cache ---

  static const _userCacheKey = 'cached_user';

  Future<void> cacheUserRaw(String json) async {
    await _prefs.setString(_userCacheKey, json);
  }

  String? getCachedUserRaw() {
    return _prefs.getString(_userCacheKey);
  }
}
