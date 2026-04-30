import 'package:pocketflow/features/wallet/data/models/wallet_model.dart';

class WalletState {
  final double? balance;
  final WalletModel? wallet;
  // final bool isLoading;
  // final String? errorMessage;

  WalletState({
    this.balance = 0.0,
    this.wallet,
    // this.isLoading = true, // Start as true for the shimmer
    // this.errorMessage,
  });

  WalletState copyWith({
    double? balance,
    WalletModel? wallet,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      wallet: wallet ?? this.wallet,
      // isLoading: isLoading ?? this.isLoading,
      // errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
