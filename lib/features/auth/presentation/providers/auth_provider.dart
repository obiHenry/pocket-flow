import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/local_storage/local_storage_services.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/datasource/auth_remote_datasource_impl.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

// 1. Data Source Provider
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// 2. Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authDataSourceProvider));
});

// final localServiceProvider = Provider<LocalStorageService>((ref) {
//   return LocalStorageService(ref.read(sharedPreferencesProvider));
// });

// 3. State Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
