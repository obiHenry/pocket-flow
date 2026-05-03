import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/features/wallet/presentation/providers/wallet_notifier.dart';
import 'package:pocketflow/features/wallet/presentation/providers/wallet_state.dart';

// autoDispose: wallet state is scoped to the wallet tab and should be
// released when the user navigates away, avoiding stale mock data in memory.
final walletProvider = AsyncNotifierProvider.autoDispose<WalletNotifier, WalletState>(
  () => WalletNotifier(),
);
