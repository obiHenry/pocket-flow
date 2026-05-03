import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketflow/features/auth/domain/entities/app_user.dart';

class UserModel extends AppUser {
  final String? currency;
  final bool isPremium;
  final DateTime? createdAt;
  final double? balance;
  final String? plan;

  const UserModel({
    super.phoneNumber,
    super.displayName,
    super.email,
    super.photoUrl,
    this.currency = 'USD', // Default value
    this.isPremium = false,
    this.createdAt,
    super.uid,
    super.isEmailVerified,
    this.balance, // Default balance for new users
    this.plan,
  });

  // 1. Convert Firestore Document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) =>
      UserModel.from(map, documentId);

  factory UserModel.from(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      currency: map['currency'] ?? 'USD',
      isPremium: map['plan'] != null
          ? (map['plan'] as String?) != 'free'
          : false, // If 'plan' field exists and is not 'free', user is premium. If it doesn't exist, default to true for backward compatibility.
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      isEmailVerified: map['isEmailVerified'] ?? false,
      balance: (map['balance'] as num?)?.toDouble(),
      plan: map['plan'] as String? ?? 'free',
    );
  }

  // 2. Convert UserModel to Map for Firestore Upload
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'phone': phoneNumber,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'currency': currency,
      'balance': balance,
      'isPremium': isPremium,
      'plan': plan,
      // createdAt is intentionally excluded — it is set once at account creation
      // and never overwritten. Writing it here as an ISO string would corrupt the
      // Firestore Timestamp that fromMap expects.
    }..removeWhere((_, v) => v == null);
  }

  // 3. Helper for State Management (Immutability)
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? currency,
    bool? isPremium,
    String? phoneNumber,
    DateTime? createdAt,
    bool? isEmailVerified,
    double? balance,
    String? plan,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      currency: currency ?? this.currency,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      balance: balance ?? this.balance,
      plan: plan ?? this.plan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'currency': currency,
      'balance': balance,
      'isPremium': isPremium,
      'plan': plan,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.toIso8601String(),
    }..removeWhere((_, v) => v == null);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      balance: (json['balance'] as num?)?.toDouble(),
      isPremium: json['isPremium'] as bool? ?? false,
      plan: json['plan'] as String? ?? 'free',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  // 4. Equatable ensures Riverpod only triggers UI rebuilds if data actually changes
  @override
  List<Object?> get props => [
    uid,
    displayName,
    email,
    photoUrl,
    currency,
    isPremium,
    createdAt,
    balance,
    plan,
  ];
}
