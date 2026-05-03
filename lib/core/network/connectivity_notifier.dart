import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield initial != ConnectivityResult.none;
  yield* connectivity.onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );
});
