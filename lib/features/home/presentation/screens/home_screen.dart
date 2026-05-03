import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/features/transaction/presentation/providers/transaction_provider.dart';

import '../../../../core/animations/animation_helper.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/balance_card.dart';
import '../widgets/currency_ticker.dart';
import '../widgets/expense_chart.dart';
import '../widgets/quick_action_row.dart';
import '../../../transaction/presentation/widgets/transaction_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final transactionAsync = ref.watch(transactionProvider);

    final hPadding = AppSpacing.getHorizontalPadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Padding(padding: hPadding, child: const CurrencyTicker()),
            ),
            //
            // flexibleSpace: (
            //   preferredSize: const Size.fromHeight(36),
            //   child: Padding(padding: hPadding, child: const CurrencyTicker()),
            // ),
          ),

          SliverToBoxAdapter(
            child: AnimationHelper.fadeInSlide(
              child: Padding(
                padding: hPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Overview", style: AppTextStyles.h2),
                    Text(
                      "Your financial health at a glance",
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                    AppSpacing.vMd,
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: hPadding,
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildMainContent()),
                        AppSpacing.hLg,
                        Expanded(
                          flex: 1,
                          child: TransactionTile(
                            transaction: transactionAsync,
                            fromTab: true,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMainContent(),
                        AppSpacing.vLg,
                        TransactionTile(
                          transaction: transactionAsync,
                          fromTab: true,
                          headerText: 'Recent Transactions',
                          seeAllText: 'See all',
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        AnimationHelper.fadeInSlide(delay: 100, child: BalanceCard()),
        AppSpacing.vLg,
        AnimationHelper.fadeInSlide(delay: 200, child: QuickActionsRow()),
        AppSpacing.vLg,
        AnimationHelper.fadeInSlide(delay: 300, child: ExpenseChart()),
      ],
    );
  }
}
