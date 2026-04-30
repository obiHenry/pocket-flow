import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String? uid;
  final String? email;
  final bool? isEmailVerified;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  const AppUser({
    this.uid,
    this.email,
    this.isEmailVerified,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
  }

  @override
  // TODO: implement props
  @override
  List<Object?> get props => [
    uid,
    displayName,
    email,
    photoUrl,
    isEmailVerified,
    phoneNumber,
  ];
}
