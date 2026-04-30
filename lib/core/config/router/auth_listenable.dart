import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// A helper class that listens to a Riverpod provider and
/// notifies the Router to re-evaluate the redirect logic.
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    ref.listen(authStreamProvider, (previous, next) {
      notifyListeners();
    });
  }
}
