import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/local_storage/local_storage_provider.dart';
import '../../../../../core/network/connectivity_notifier.dart';
import '../../../../../core/offline/offline_queue_provider.dart';
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

    // Flush queued actions whenever we come back online
    ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.valueOrNull == false;
      final isNowOnline = next.valueOrNull == true;
      if (wasOffline && isNowOnline) _flushQueue();
    });

    return _fetchFirstPage();
  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ---------------------------------------------------------------------------
  // FETCH
  // ---------------------------------------------------------------------------

  Future<List<TransactionModel>> _fetchFirstPage() async {
    _lastDoc = null;
    _hasMore = true;

    if (!await _isOnline()) {
      return _loadFromCache();
    }

    final result = await _repo.fetchTransactionsPaginated(limit: _pageSize);
    return result.fold((e) => throw e, (page) {
      _allTransactions = page.transactions;
      _lastDoc = page.lastDoc;
      _hasMore = page.transactions.length == _pageSize;
      _cacheTransactions();
      return _allTransactions;
    });
  }

  List<TransactionModel> _loadFromCache() {
    final uid = ref.read(userProvider).valueOrNull?.uid;
    if (uid == null) return [];
    final raw = ref.read(localStorageProvider).getCachedTransactionsRaw(uid);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    _allTransactions = decoded
        .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _hasMore = false;
    return _allTransactions;
  }

  void _cacheTransactions() {
    final uid = ref.read(userProvider).valueOrNull?.uid;
    if (uid == null) return;
    final json = jsonEncode(_allTransactions.map((t) => t.toJson()).toList());
    ref.read(localStorageProvider).cacheTransactionsRaw(uid, json);
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

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Future<String?> addTransaction({
    required String merchantName,
    required double amount,
    required String typeLabel,
    required String category,
  }) async {
    if (!await _isOnline()) {
      return _queueAdd(
        merchantName: merchantName,
        amount: amount,
        typeLabel: typeLabel,
        category: category,
      );
    }
    return _addTransactionOnServer(
      merchantName: merchantName,
      amount: amount,
      typeLabel: typeLabel,
      category: category,
    );
  }

  // Optimistically adds a placeholder and queues for later sync.
  Future<String?> _queueAdd({
    required String merchantName,
    required double amount,
    required String typeLabel,
    required String category,
  }) async {
    final tempId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
    final tempTx = TransactionModel(
      id: tempId,
      merchantName: merchantName,
      category: category,
      type: TransactionModel.typeFromLabel(typeLabel),
      amount: amount,
      date: DateTime.now(),
    );

    _allTransactions = [tempTx, ..._allTransactions];
    state = AsyncData([..._allTransactions]);

    await ref.read(offlineQueueProvider).enqueue('add_transaction', {
      'tempId': tempId,
      'merchantName': merchantName,
      'amount': amount,
      'typeLabel': typeLabel,
      'category': category,
    });

    return null;
  }

  // Does the actual Firestore write + balance update.
  Future<String?> _addTransactionOnServer({
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
    final updatedUser = currentUser.copyWith(
      balance:
          currentBalance + (transaction.type == 'Credit' ? amount : -amount),
    );

    final txFuture = _repo.addTransaction(transaction);
    final userFuture =
        ref.read(userProvider.notifier).updateUser(updatedUser);

    final txResult = await txFuture;
    final userError = await userFuture;

    final txError = txResult.fold((e) => e.message, (_) => null);
    if (txError != null) return txError;
    if (userError != null) return userError;

    final savedTx = txResult.getOrElse(() => transaction);
    _allTransactions = [savedTx, ..._allTransactions];
    state = AsyncData([..._allTransactions]);
    _cacheTransactions();
    return null;
  }

  Future<String?> deleteTransaction(String id) async {
    if (!await _isOnline()) {
      return 'Cannot delete transactions while offline. Please reconnect and try again.';
    }

    final currentUser = ref.read(userProvider).valueOrNull;
    if (currentUser == null || currentUser.uid == null) {
      return 'User session not available. Please try again.';
    }

    final tx = _allTransactions.firstWhere((tx) => tx.id == id);
    final currentBalance = currentUser.balance ?? 0.0;
    final updatedUser = currentUser.copyWith(
      balance:
          currentBalance + (tx.type == 'Credit' ? -tx.amount : tx.amount),
    );

    final deleteResult = await _repo.deleteTransaction(id);
    final deleteError = deleteResult.fold((e) => e.message, (_) => null);
    if (deleteError != null) return deleteError;

    final userError =
        await ref.read(userProvider.notifier).updateUser(updatedUser);
    if (userError != null) return userError;

    _allTransactions.removeWhere((tx) => tx.id == id);
    state = AsyncData([..._allTransactions]);
    _cacheTransactions();
    return null;
  }

  Future<String?> editTransaction(TransactionModel updatedTx) async {
    if (!await _isOnline()) {
      return 'Cannot edit transactions while offline. Please reconnect and try again.';
    }

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
    final userFuture =
        ref.read(userProvider.notifier).updateUser(updatedUser);

    final editResult = await editFuture;
    final userError = await userFuture;

    final editError = editResult.fold((e) => e.message, (_) => null);
    if (editError != null) return editError;
    if (userError != null) return userError;

    _allTransactions[index] = updatedTx;
    state = AsyncData([..._allTransactions]);
    _cacheTransactions();
    return null;
  }

  // ---------------------------------------------------------------------------
  // QUEUE FLUSH
  // ---------------------------------------------------------------------------

  Future<void> _flushQueue() async {
    final queue = ref.read(offlineQueueProvider).getQueue();
    if (queue.isEmpty) return;

    for (final item in List<Map<String, dynamic>>.from(queue)) {
      final type = item['type'] as String;
      final payload = Map<String, dynamic>.from(item['payload'] as Map);
      final queueId = item['id'] as String;

      if (type == 'add_transaction') {
        // Remove the offline placeholder from local state
        final tempId = payload['tempId'] as String;
        _allTransactions.removeWhere((tx) => tx.id == tempId);
        state = AsyncData([..._allTransactions]);

        final error = await _addTransactionOnServer(
          merchantName: payload['merchantName'] as String,
          amount: (payload['amount'] as num).toDouble(),
          typeLabel: payload['typeLabel'] as String,
          category: payload['category'] as String,
        );

        if (error == null) {
          await ref.read(offlineQueueProvider).remove(queueId);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH & FILTER
  // ---------------------------------------------------------------------------

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
        state = AsyncData(
          _allTransactions.where((tx) => tx.category == filter).toList(),
        );
    }
  }
}
