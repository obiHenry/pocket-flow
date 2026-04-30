import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocketflow/core/constants/app_spacing.dart';
import 'package:pocketflow/features/transaction/presentation/providers/transaction_provider.dart';

import '../../../../core/animations/animation_helper.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../transaction/presentation/widgets/transaction_section.dart';
import '../widgets/asset_allocation.dart';
import '../widgets/card_stack.dart';
import '../widgets/wallet_loading_skeleton.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final transactionAsync = ref.watch(transactionProvider);
    final transactions = transactionAsync.valueOrNull ?? [];

    final now = DateTime.now();
    final monthTxs = transactions.where(
      (tx) => tx.date.year == now.year && tx.date.month == now.month,
    );
    final monthlyIncome = monthTxs
        .where((tx) => tx.type == 'Credit')
        .fold(0.0, (s, tx) => s + tx.amount);
    final monthlyExpense = monthTxs
        .where((tx) => tx.type == 'Debit')
        .fold(0.0, (s, tx) => s + tx.amount);

    return Scaffold(
      body: userAsync.when(
        loading: () => const WalletLoadingSkeleton(),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (user) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              flexibleSpace: FlexibleSpaceBar(
                background: AnimationHelper.fadeInSlide(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: CardStack(
                      balance: user?.balance ?? 0.0,
                      monthlyExpense: monthlyExpense,
                      monthlyIncome: monthlyIncome,
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: AnimationHelper.fadeInSlide(
                delay: 200,
                child: const AssetAllocationSection(),
              ),
            ),

            SliverFillRemaining(
              child: Padding(
                padding: AppSpacing.horizontal(AppSpacing.md.w),
                child: AnimationHelper.fadeInSlide(
                  delay: 200,
                  child: TransactionTile(
                    headerText: 'Activity',
                    transaction: transactionAsync,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
