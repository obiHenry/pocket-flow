import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      loadingAction: AuthLoadingAction.login,
    );

    final result = await _repository.login(email: email, password: password);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      loadingAction: AuthLoadingAction.signUp,
    );

    // 1. Create the Firebase Auth account
    final result = await _repository.signUp(email: email, password: password);
    print('process starting');

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );

        print(state.errorMessage);
      },

      (user) async {
        final results = await Future.wait([
          _repository.updateUserProfile(userId: user.uid!, displayName: name),
          _repository.createUserProfile(
            userId: user.uid!,
            email: email,
            displayName: name,
          ),
        ]);

        final failure = results
            .map((r) => r.fold((l) => l, (_) => null))
            .firstWhere((e) => e != null, orElse: () => null);

        // Always authenticate — profile write failures are non-blocking.
        // errorMessage is set so the UI can show a snackbar warning.
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: failure?.message,
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      loadingAction: AuthLoadingAction.google,
    );

    final result = await _repository.signInWithGoogle();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      loadingAction: AuthLoadingAction.apple,
    );

    final result = await _repository.signInWithApple();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) =>
          state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.resetPassword(email: email);

    result.fold(
      (l) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: l.message,
      ),
      (r) => state = state.copyWith(
        status: AuthStatus.initial,
      ), // Or a "Success" state
    );
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      loadingAction: AuthLoadingAction.logout,
    );

    final result = await _repository.logout();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> checkSession() async {
    // 1. Check if user is logged into Firebase
    final userResult = await _repository.getCurrentUser();

    userResult.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        } else {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            // Custom flag if you want to differentiate "New User" vs "Logged Out"
          );
        }
      },
    );
  }
}
