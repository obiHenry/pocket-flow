import '../../domain/entities/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

enum AuthLoadingAction { none, login, signUp, google, apple, logout }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;
  final AuthLoadingAction loadingAction;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.loadingAction = AuthLoadingAction.none,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    AuthLoadingAction? loadingAction,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      loadingAction: loadingAction ?? this.loadingAction,
    );
  }
}
