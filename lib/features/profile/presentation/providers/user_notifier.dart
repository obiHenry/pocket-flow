import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../data/models/user_model.dart';
import '../../domain/repository/user_repository.dart';
import 'user_provider.dart';

class UserNotifier extends AsyncNotifier<UserModel?> {
  // _repo is assigned once in build() and reused by all action methods.
  // This avoids calling ref.read(userRepositoryProvider) everywhere.
  late UserRepository _repo;

  UserModel? userDetails; // Master user data — kept in sync with Firebase.

  @override
  FutureOr<UserModel?> build() async {
    // Assign the repository once here — available to all methods below.
    _repo = ref.read(userRepositoryProvider);

    return _fetchUser();
  }

  Future<UserModel> _fetchUser() async {
    final result = await _repo.fetchCurrentUser();

    return result.fold((exception) => throw exception, (user) {
      userDetails = user;
      return userDetails!;
    });
  }

  // ---------------------------------------------------------------------------
  // GET USER
  // ---------------------------------------------------------------------------

  /// Re-fetches the current user from Firebase and refreshes state.
  /// Useful after a profile update to confirm the latest data from the server.
  // Future<void> getUer() async {
  //   state = const AsyncLoading();

  //   final result = await _repo.fetchCurrentUser();

  //   state = result.fold(
  //     (exception) => AsyncError(exception, StackTrace.current),
  //     (user) => AsyncData(user),
  //   );
  // }

  // ---------------------------------------------------------------------------
  // UPDATE USER
  // ---------------------------------------------------------------------------

  /// Optimistically updates the UI immediately, then syncs to Firebase.
  /// Rolls back to the previous state if Firebase returns an error.
  /// Returns null on success, or an error message string on failure.
  Future<String?> updateUser(UserModel updatedUser) async {
    final previousState = state.value;

    // Optimistic update — show the new data in the UI right away.
    state = AsyncData(updatedUser);

    final result = await _repo.updateUser(updatedUser);

    return result.fold(
      (exception) {
        // Rollback — restore the old data so the UI stays accurate.
        state = AsyncData(previousState);
        return exception.message;
      },
      (_) => null,
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE USER
  // ---------------------------------------------------------------------------

  /// Deletes the user's Firestore profile and Firebase Auth account.
  /// On success, clears state to null — the app's auth guard should redirect.
  Future<void> deleteUser() async {
    final userId = state.value?.uid;
    if (userId == null) return;

    state = const AsyncLoading();

    final result = await _repo.deleteUser(userId);

    result.fold(
      (exception) => state = AsyncError(exception, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  // ---------------------------------------------------------------------------
  // LOG OUT
  // ---------------------------------------------------------------------------

  /// Signs the user out of Firebase Auth and clears the user state.
  Future<void> logOut() async {
    state = const AsyncLoading();

    final result = await _repo.logOut();

    result.fold(
      (exception) => state = AsyncError(exception, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK MODE
  // ---------------------------------------------------------------------------

  /// Toggles dark/light mode via the ThemeNotifier.
  /// This is a UI-only operation — no Firebase call needed.
  void updateDarkMode() {
    ref.read(themeProvider.notifier).toggle();
  }
}
