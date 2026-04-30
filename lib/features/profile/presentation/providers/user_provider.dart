import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/user_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repository/user_repository_impl.dart';
import '../../domain/repository/user_repository.dart';
import 'user_notifier.dart';

/// Provides the datasource — one instance shared across the app.
final userDataSourceProvider = Provider<UserRemoteDataSource>(
  (_) => UserRemoteDataSourceImpl(),
);

/// Provides the repository — depends on the datasource above.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(ref.read(userDataSourceProvider)),
);

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  () => UserNotifier(),
);
