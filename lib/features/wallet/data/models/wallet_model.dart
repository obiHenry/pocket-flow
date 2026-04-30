class WalletModel {
  final double? balance;
  final List? transactions;

  WalletModel({this.balance, this.transactions});

  factory WalletModel.fromFirebase(Map<String, dynamic> firebase) {
    return WalletModel(
      balance: firebase['balance'],
      transactions: firebase['transaction'],
    );
  }

  WalletModel copyWith({final double? balance, final List? transactions}) {
    return WalletModel(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }
}
