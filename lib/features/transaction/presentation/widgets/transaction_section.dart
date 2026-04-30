import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketflow/core/constants/app_colors.dart';
import 'package:pocketflow/features/transaction/data/models/transaction_model.dart';
import 'package:pocketflow/features/transaction/presentation/widgets/transaction_skeleton.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_picker.dart';
import '../widgets/transaction_type.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';

class TransactionTile extends ConsumerStatefulWidget {
  final bool fromTab;
  final String? headerText;
  final String? seeAllText;
  final AsyncValue transaction;

  const TransactionTile({
    super.key,
    this.fromTab = false,
    required this.transaction,
    this.headerText,
    this.seeAllText,
  });

  @override
  ConsumerState<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<TransactionTile> {
  final _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (!widget.fromTab) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(transactionProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _goToNextPage(int pagesLoaded, bool hasMore) async {
    if (_currentPage < pagesLoaded) {
      setState(() => _currentPage++);
    } else if (hasMore) {
      await ref.read(transactionProvider.notifier).loadMore();
      if (mounted) setState(() => _currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return widget.transaction.when(
      loading: () => const TransactionSkeleton(),
      error: (err, _) =>
          const Center(child: Text("Failed to load transactions")),
      data: (transactions) {
        final list = transactions as List<TransactionModel>;

        // Full mobile view — ListView owns the scroll for pagination.
        if (!isDesktop && !widget.fromTab) {
          return _mobileListView(list);
        }

        // Embedded / tab view — Column, no pagination scroll.
        if (widget.fromTab) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.headerText != null && widget.seeAllText != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.headerText!, style: AppTextStyles.h3),
                    TextButton(
                      onPressed: () {},
                      child: Text(widget.seeAllText!),
                    ),
                  ],
                ),
              ],
              AppSpacing.vMd,
              _mobileColumn(list),
            ],
          );
        }

        // Desktop — page-replacement table + pagination bar.
        final notifier = ref.read(transactionProvider.notifier);
        final pageSize = notifier.pageSize;
        final pagesLoaded = (list.length / pageSize).ceil().clamp(1, 9999);
        final safePage = _currentPage.clamp(1, pagesLoaded);
        final start = (safePage - 1) * pageSize;
        final end = (start + pageSize).clamp(0, list.length);
        final pageItems = list.sublist(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.headerText != null && widget.seeAllText != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.headerText!, style: AppTextStyles.h3),
                  TextButton(onPressed: () {}, child: Text(widget.seeAllText!)),
                ],
              ),
              AppSpacing.vMd,
            ],
            Expanded(
              child: _desktopView(
                pageItems,
                context,
                _desktopPaginationBar(
                  pagesLoaded: pagesLoaded,
                  currentPage: safePage,
                  hasMore: notifier.hasMore,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _mobileListView(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return const EmptyState();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: transactions.length,
      itemBuilder: (_, i) => _mobileTile(transactions[i]),
    );
  }

  Widget _mobileColumn(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return const EmptyState();
    return Column(children: transactions.map(_mobileTile).toList());
  }

  Widget _mobileTile(TransactionModel e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: Icon(
              e.type == 'Credit' ? Icons.arrow_upward : Icons.arrow_downward,
              color: e.type == 'Credit' ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.merchantName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(e.category, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                "₦${e.amount.toStringAsFixed(2)}",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: e.type == 'Credit'
                      ? AppColors.success
                      : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _TransactionActionsMenu(transaction: e),
            ],
          ),
        ],
      ),
    );
  }

  Widget _desktopPaginationBar({
    required int pagesLoaded,
    required int currentPage,
    required bool hasMore,
  }) {
    final isOnLastPage = currentPage == pagesLoaded;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            onPressed: currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous',
          ),
          const SizedBox(width: 4),
          // Page number chips
          ...List.generate(pagesLoaded, (i) {
            final page = i + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _PageChip(
                page: page,
                isActive: page == currentPage,
                onTap: () => setState(() => _currentPage = page),
              ),
            );
          }),
          const SizedBox(width: 4),
          // Load More / Next button
          if (isOnLastPage && hasMore)
            TextButton.icon(
              onPressed: () => _goToNextPage(pagesLoaded, hasMore),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Load More"),
            )
          else if (!isOnLastPage)
            IconButton(
              onPressed: () => setState(() => _currentPage++),
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next',
            ),
        ],
      ),
    );
  }

  Widget _desktopView(
    List<TransactionModel> transactions,
    BuildContext context,
    Widget paginationBar,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: transactions.isEmpty
          ? const EmptyState()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(1.5),
                        5: FixedColumnWidth(50),
                      },
                      children: [
                        _buildHeaderRow(),
                        ...transactions.map((e) => _buildDataRow(context, e)),
                      ],
                    ),
                  ),
                ),
                // const Divider(height: 24),
                paginationBar,
              ],
            ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.05)),
        ),
      ),
      children: [
        _headerCell("MERCHANT"),
        _headerCell("CATEGORY"),
        _headerCell("TYPE"),
        _headerCell("DATE"),
        _headerCell("AMOUNT"),
        _headerCell("ACTION"),
      ],
    );
  }

  Widget _headerCell(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  TableRow _buildDataRow(BuildContext context, TransactionModel e) {
    final color = e.type == 'Credit' ? AppColors.success : AppColors.error;
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey.withValues(alpha: 0.05)),
        ),
      ),
      children: [
        _dataCell(
          child: Text(
            e.merchantName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _dataCell(child: Text(e.category, style: AppTextStyles.bodySmall)),
        _dataCell(
          child: Text(
            e.type,
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ),
        _dataCell(child: Text(e.formattedDate, style: AppTextStyles.bodySmall)),
        _dataCell(
          child: Text(
            "₦${e.amount.toStringAsFixed(2)}",
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _dataCell(child: _TransactionActionsMenu(transaction: e)),
      ],
    );
  }

  Widget _dataCell({required Widget child}) => TableCell(
    verticalAlignment: TableCellVerticalAlignment.middle,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: child,
    ),
  );
}

// =============================================================================
// PAGE CHIP — numbered chip for the desktop pagination bar
// =============================================================================

class _PageChip extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;
  const _PageChip({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ACTIONS MENU — ConsumerWidget so it can read the notifier for delete/edit
// =============================================================================

class _TransactionActionsMenu extends ConsumerWidget {
  final TransactionModel transaction;
  const _TransactionActionsMenu({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _showViewModal(context, transaction);
          case 'edit':
            _showEditModal(context, ref, transaction);
          case 'delete':
            _showDeleteConfirmDialog(context, ref, transaction);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: _MenuLabel(Icons.visibility_outlined, "View Details"),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: _MenuLabel(Icons.edit_outlined, "Edit"),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuLabel(
            Icons.delete_outline,
            "Delete",
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuLabel(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }
}

// =============================================================================
// VIEW MODAL — read-only detail rows, label left / value right
// =============================================================================

void _showViewModal(BuildContext context, TransactionModel tx) {
  final isDesktop = ResponsiveHelper.isDesktop(context);
  final isTablet = ResponsiveHelper.isTablet(context);
  if (isDesktop || isTablet) {
    HelperFunctions.showModal(
      context: context,
      widget: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _ViewTransactionSheet(transaction: tx),
        ),
      ),
    );
  } else {
    HelperFunctions.showCustomBottomSheet(
      context: context,
      child: _ViewTransactionSheet(transaction: tx),
    );
  }
}

class _ViewTransactionSheet extends StatelessWidget {
  final TransactionModel transaction;
  const _ViewTransactionSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'Credit';
    final amountColor = isCredit ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.vMd,
          Text("Transaction Details", style: AppTextStyles.h2),
          AppSpacing.vLg,
          _DetailRow(label: "Merchant", value: transaction.merchantName),
          _DetailRow(label: "Category", value: transaction.category),
          _DetailRow(
            label: "Type",
            value: transaction.type,
            valueColor: amountColor,
          ),
          _DetailRow(
            label: "Amount",
            value: "₦${transaction.amount.toStringAsFixed(2)}",
            valueColor: amountColor,
          ),
          _DetailRow(label: "Date", value: transaction.formattedDate),
          AppSpacing.vLg,
          AppButton(
            text: "Close",
            isOutlined: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Single detail row: label on the left, value on the right.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EDIT MODAL — pre-filled form, saves via notifier on "Save Changes"
// =============================================================================

void _showEditModal(
  BuildContext context,
  WidgetRef ref,
  TransactionModel transaction,
) {
  final isDesktop = ResponsiveHelper.isDesktop(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  if (isDesktop || isTablet) {
    HelperFunctions.showModal(
      context: context,
      showExitButton: true,
      widget: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _EditTransactionSheet(transaction: transaction, ref: ref),
        ),
      ),
    );
  } else {
    HelperFunctions.showCustomBottomSheet(
      context: context,
      isScrollControlled: true,
      child: _EditTransactionSheet(transaction: transaction, ref: ref),
    );
  }
}
// void _showEditModal(
//   BuildContext context,
//   WidgetRef ref,
//   TransactionModel transaction,
// ) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//     ),
//     builder: (_) => _EditTransactionSheet(transaction: transaction, ref: ref),
//   );
// }

class _EditTransactionSheet extends StatefulWidget {
  final TransactionModel transaction;
  // ref is passed in so the sheet can call the notifier even though it's
  // a plain StatefulWidget (not ConsumerStatefulWidget).
  final WidgetRef ref;
  const _EditTransactionSheet({required this.transaction, required this.ref});

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late String _type; // 'Expense' or 'Income' — maps to 'Debit'/'Credit'
  late String _category;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(
      text: widget.transaction.merchantName,
    );
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    // Convert from stored type ('Credit'/'Debit') to selector label ('Income'/'Expense').
    _type = TransactionModel.labelFromType(widget.transaction.type);
    _category = widget.transaction.category;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final merchant = _merchantController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (merchant.isEmpty || amount == null) {
      HelperFunctions.showSnackBar(
        "Please fill in all fields",
        context,
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedTx = widget.transaction.copyWith(
      merchantName: merchant,
      amount: amount,
      type: TransactionModel.typeFromLabel(_type),
      category: _category,
    );

    final error = await widget.ref
        .read(transactionProvider.notifier)
        .editTransaction(updatedTx);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pop(context);
      HelperFunctions.showSnackBar("Transaction updated successfully", context);
    } else {
      HelperFunctions.showSnackBar(error, context, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.vMd,
            Text("Edit Transaction", style: AppTextStyles.h2),
            AppSpacing.vLg,
            TransactionTypeSelector(
              initialValue: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            AppSpacing.vMd,
            AppTextField(
              controller: _amountController,
              hint: "Amount",
              keyboardType: TextInputType.number,
            ),
            AppSpacing.vMd,
            AppTextField(
              controller: _merchantController,
              hint: "e.g., Grocery Shopping",
            ),
            AppSpacing.vMd,
            CategoryPicker(
              initialValue: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            AppSpacing.vLg,
            AppButton(
              text: "Save Changes",
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _save,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DELETE CONFIRM DIALOG
// =============================================================================

void _showDeleteConfirmDialog(
  BuildContext context,
  WidgetRef ref,
  TransactionModel tx,
) {
  showDialog(
    context: context,
    builder: (_) {
      bool loading = false;

      // ✅ Wrap with StatefulBuilder to get setState inside dialog
      return StatefulBuilder(
        builder: (context, setState) {
          // ← this setState rebuilds the dialog
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Delete Transaction"),
            content: Text(
              'Are you sure you want to delete "${tx.merchantName}"?\nThis action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: loading
                    ? null // ← disable cancel while deleting
                    : () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: loading
                    ? null // ← disable button while loading
                    : () async {
                        setState(() => loading = true); // ← now works ✅
                        final result = await ref
                            .read(transactionProvider.notifier)
                            .deleteTransaction(tx.id);
                        setState(() => loading = false);

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (result == null) {
                          HelperFunctions.showSnackBar(
                            "Transaction deleted successfully",
                            context,
                          );
                        } else {
                          HelperFunctions.showSnackBar(
                            result,
                            context,
                            isError: true,
                          );
                        }
                      },
                child: Text(
                  loading ? "Deleting..." : "Delete",
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
