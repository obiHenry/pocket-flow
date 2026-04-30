import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repository/transaction_repository.dart';
import 'transaction_provider.dart';

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  late TransactionRepository _repo;

  List<TransactionModel> _allTransactions = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  static const _pageSize = 20;

  bool get hasMore => _hasMore;
  int get pageSize => _pageSize;

  @override
  FutureOr<List<TransactionModel>> build() async {
    _repo = ref.read(transactionRepositoryProvider);
    return _fetchFirstPage();
  }

  Future<List<TransactionModel>> _fetchFirstPage() async {
    _lastDoc = null;
    _hasMore = true;

    final result = await _repo.fetchTransactionsPaginated(limit: _pageSize);
    return result.fold((e) => throw e, (page) {
      _allTransactions = page.transactions;
      _lastDoc = page.lastDoc;
      _hasMore = page.transactions.length == _pageSize;
      return _allTransactions;
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchFirstPage);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;

    final result = await _repo.fetchTransactionsPaginated(
      limit: _pageSize,
      startAfter: _lastDoc,
    );

    result.fold((_) {}, (page) {
      _allTransactions = [..._allTransactions, ...page.transactions];
      _lastDoc = page.lastDoc;
      _hasMore = page.transactions.length == _pageSize;
      state = AsyncData([..._allTransactions]);
    });

    _isLoadingMore = false;
  }

  // --- ACTIONS ---

  /// Returns null on success, or an error message string on failure.
  /// The UI passes raw form values — model building happens here, not in the UI.

  Future<String?> addTransaction({
    required String merchantName,
    required double amount,
    required String typeLabel,
    required String category,
  }) async {
    final currentUser = await ref.read(userProvider.future);
    if (currentUser == null || currentUser.uid == null) {
      return 'User session not available. Please try again.';
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchantName: merchantName,
      category: category,
      type: TransactionModel.typeFromLabel(typeLabel),
      amount: amount,
      date: DateTime.now(),
    );

    final currentBalance = currentUser.balance ?? 0.0;
    print('Current balance: $currentBalance');

    final updatedUser = currentUser.copyWith(
      balance:
          currentBalance + (transaction.type == 'Credit' ? amount : -amount),
    );

    // Start both in parallel then await each — they have different return types
    // so Future.wait can't fold them uniformly.
    final txFuture = _repo.addTransaction(transaction);
    final userFuture = ref.read(userProvider.notifier).updateUser(updatedUser);

    final txResult = await txFuture;
    final userError = await userFuture;

    final txError = txResult.fold((e) => e.message, (_) => null);
    if (txError != null) return txError;
    if (userError != null) return userError;

    final savedTx = txResult.getOrElse(() => transaction);
    _allTransactions = [savedTx, ..._allTransactions];
    state = AsyncData([..._allTransactions]);
    return null;
  }

  Future<String?> deleteTransaction(String id) async {
    final currentUser = ref.read(userProvider).valueOrNull;
    if (currentUser == null || currentUser.uid == null) {
      return 'User session not available. Please try again.';
    }

    final tx = _allTransactions.firstWhere((tx) => tx.id == id);
    final currentBalance = currentUser.balance ?? 0.0;
    final updatedUser = currentUser.copyWith(
      balance: currentBalance + (tx.type == 'Credit' ? -tx.amount : tx.amount),
    );

    final deleteResult = await _repo.deleteTransaction(id);
    final deleteError = deleteResult.fold((e) => e.message, (_) => null);
    if (deleteError != null) return deleteError;

    final userError = await ref
        .read(userProvider.notifier)
        .updateUser(updatedUser);
    if (userError != null) return userError;

    _allTransactions.removeWhere((tx) => tx.id == id);
    state = AsyncData([..._allTransactions]);
    return null;
  }

  Future<String?> editTransaction(TransactionModel updatedTx) async {
    final currentUser = ref.read(userProvider).valueOrNull;
    if (currentUser == null || currentUser.uid == null) {
      return 'User session not available. Please try again.';
    }

    final index = _allTransactions.indexWhere((tx) => tx.id == updatedTx.id);
    if (index == -1) return 'Transaction not found in local state.';

    final oldTx = _allTransactions[index];
    final currentBalance = currentUser.balance ?? 0.0;
    final balanceDelta =
        (updatedTx.type == 'Credit' ? updatedTx.amount : -updatedTx.amount) -
        (oldTx.type == 'Credit' ? oldTx.amount : -oldTx.amount);

    final updatedUser = currentUser.copyWith(
      balance: currentBalance + balanceDelta,
    );

    final editFuture = _repo.editTransaction(updatedTx);
    final userFuture = ref.read(userProvider.notifier).updateUser(updatedUser);

    final editResult = await editFuture;
    final userError = await userFuture;

    final editError = editResult.fold((e) => e.message, (_) => null);
    if (editError != null) return editError;
    if (userError != null) return userError;

    _allTransactions[index] = updatedTx;
    state = AsyncData([..._allTransactions]);
    return null;
  }

  // --- SEARCH & FILTER ---

  void searchTransactions(String query) {
    if (query.isEmpty) {
      state = AsyncData(_allTransactions);
    } else {
      final filtered = _allTransactions.where((tx) {
        return tx.merchantName.toLowerCase().contains(query.toLowerCase()) ||
            tx.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
      state = AsyncData(filtered);
    }
  }

  /// Filters the list by the selected chip label`.
  /// 'All' resets, 'Income'/'Expense' filter by type, everything else by category.
  void filterTransactions(String filter) {
    switch (filter) {
      case 'All':
        state = AsyncData([..._allTransactions]);
      case 'Income':
        state = AsyncData(
          _allTransactions.where((tx) => tx.type == 'Credit').toList(),
        );
      case 'Expense':
        state = AsyncData(
          _allTransactions.where((tx) => tx.type == 'Debit').toList(),
        );
      default:
        // Category-based filter: Shopping, Bills, etc.
        state = AsyncData(
          _allTransactions.where((tx) => tx.category == filter).toList(),
        );
    }
  }
}
