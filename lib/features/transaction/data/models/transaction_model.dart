import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final String merchantName;
  final String category;
  final String type; // 'Credit' or 'Debit'
  final double amount;
  final DateTime date;
  final bool hasReceipt;

  const TransactionModel({
    required this.id,
    this.userId = '',
    required this.merchantName,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
    this.hasReceipt = false,
  });

  // UI labels ('Income'/'Expense') → stored values ('Credit'/'Debit')
  static String typeFromLabel(String label) =>
      label == 'Income' ? 'Credit' : 'Debit';

  // Stored values ('Credit'/'Debit') → UI labels ('Income'/'Expense')
  static String labelFromType(String type) =>
      type == 'Credit' ? 'Income' : 'Expense';

  String get formattedDate =>
      "${date.day} ${_getMonth(date.month)} ${date.year}";

  String _getMonth(int month) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  // copyWith for easy editing
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? merchantName,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    bool? hasReceipt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      hasReceipt: hasReceipt ?? this.hasReceipt,
    );
  }

  factory TransactionModel.fromFirebase(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      merchantName: data['merchantName'],
      category: data['category'],
      type: data['type'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as dynamic).toDate(),
      hasReceipt: data['hasReceipt'] ?? false,
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      // 'id' is NOT sent on initial create — Firestore generates it.
      // It is stamped onto the document separately after creation (see addTransaction).
      'userId': userId,
      'merchantName': merchantName,
      'category': category,
      'type': type,
      'amount': amount,
      'date': date,
      'hasReceipt': hasReceipt,
    };
  }

  @override
  List<Object?> get props => [id, userId, merchantName, category, type, amount, date];
}
