import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/transaction_provider.dart';
import 'category_picker.dart';
import 'transaction_type.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Expense';
  String _category = 'Shopping';
  bool _isLoading = false;

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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

    final error = await ref
        .read(transactionProvider.notifier)
        .addTransaction(
          merchantName: merchant,
          amount: amount,
          typeLabel: _type,
          category: _category,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      HelperFunctions.showSnackBar(error, context, isError: true);
    } else {
      Navigator.pop(context);
      HelperFunctions.showSnackBar('Transaction added successfully!', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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
          Text("New Transaction", style: AppTextStyles.h2),
          AppSpacing.vLg,
          TransactionTypeSelector(onChanged: (v) => setState(() => _type = v)),
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
          CategoryPicker(onChanged: (v) => setState(() => _category = v)),
          AppSpacing.vLg,
          AppButton(
            text: "Create Transaction",
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
