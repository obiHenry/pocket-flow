import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/core/utils/helper_functions.dart';
import 'package:pocketflow/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:pocketflow/shared/widgets/app_scaffold.dart';
import 'package:pocketflow/shared/widgets/app_text_field.dart';

import '../../../../core/animations/animation_helper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/transaction_section.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/transaction_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(transactionProvider.notifier)
          .searchTransactions(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionAsync = ref.watch(transactionProvider);

    return AppScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Transaction",
          style: TextStyle(color: Colors.white),
        ),
      ),
      enableRefresh: true,
      onRefresh: () => ref.read(transactionProvider.notifier).refresh(),
      body: CustomScrollView(
        slivers: [
          // Search bar collapses as you scroll down
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: AppTextField(
                controller: _searchController,
                hint: "Search transactions...",
                keyboardType: TextInputType.text,
              ),
            ),
          ),

          // Filter chips — each tap calls filterTransactions on the notifier
          const SliverToBoxAdapter(child: FilterChipRow()),

          // Transaction list — SliverFillRemaining gives the internal
          // ListView a bounded height so pagination scroll works.
          SliverFillRemaining(
            hasScrollBody: true,
            child: AnimationHelper.fadeInSlide(
              delay: 50,
              child: TransactionTile(transaction: transactionAsync),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isDesktop || isTablet) {
      HelperFunctions.showModal(
        context: context,
        showExitButton: true,
        widget: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: AddTransactionSheet(),
          ),
        ),
      );
    } else {
      HelperFunctions.showCustomBottomSheet(
        context: context,
        isScrollControlled: true,
        child: const AddTransactionSheet(),
      );
    }
  }
}
