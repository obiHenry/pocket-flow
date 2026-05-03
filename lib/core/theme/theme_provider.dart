import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_storage/local_storage_provider.dart';
import '../local_storage/local_storage_services.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  ThemeNotifier(this._storage) : super(_storage.getThemeMode());

  void setLight() {
    state = ThemeMode.light;
    _storage.saveThemeMode(state);
  }

  void setDark() {
    state = ThemeMode.dark;
    _storage.saveThemeMode(state);
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _storage.saveThemeMode(state);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ref.read(localStorageProvider)),
);
