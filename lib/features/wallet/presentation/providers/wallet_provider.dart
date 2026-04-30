import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/features/wallet/presentation/providers/wallet_notifier.dart';
import 'package:pocketflow/features/wallet/presentation/providers/wallet_state.dart';

final walletProvider = AsyncNotifierProvider<WalletNotifier, WalletState>(
  () => WalletNotifier(),
);
