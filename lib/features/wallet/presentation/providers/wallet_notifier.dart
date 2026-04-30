import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/features/wallet/presentation/providers/wallet_state.dart';

import '../../data/models/wallet_model.dart';

class WalletNotifier extends AsyncNotifier<WalletState> {
  WalletNotifier() : super();

  @override
  FutureOr<WalletState> build() {
    return _fetchInitialData();
  }

  Future<WalletState> _fetchInitialData() async {
    // MOCK DELAY: This triggers your Shimmer automatically
    await Future.delayed(const Duration(seconds: 4));

    // Once this returns, the provider switches to "Data" state
    return WalletState(
      balance: 12540.50,
      wallet: WalletModel(transactions: ['amazon', 'google', 'Ebay']),
    );
  }

  // You can add methods to "refresh" or "update" later
  Future<void> refreshBalance() async {
    state = const AsyncLoading(); // Manually trigger shimmer again
    state = await AsyncValue.guard(() => _fetchInitialData());
  }
}
