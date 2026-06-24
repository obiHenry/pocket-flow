#!/bin/bash
# Flutter Clean Architecture scaffold script
# Usage: bash create_structure.sh <new_project_path>
# Example: bash create_structure.sh ~/projects/myapp
#
# Run this from INSIDE the new Flutter project root, or pass the path as an argument.

set -e

PROJECT_DIR="${1:-.}"

if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
  echo "ERROR: No pubspec.yaml found in $PROJECT_DIR"
  echo "Create the Flutter project first with: flutter create <app_name>"
  exit 1
fi

cd "$PROJECT_DIR"
PROJECT_NAME=$(grep '^name:' pubspec.yaml | awk '{print $2}')
echo "Scaffolding clean architecture for: $PROJECT_NAME"

# ─────────────────────────────────────────────
# 1. ASSET FOLDERS
# ─────────────────────────────────────────────
mkdir -p assets/images/png
mkdir -p assets/images/svg
mkdir -p assets/icons/png
mkdir -p assets/icons/svg
mkdir -p assets/fonts

# ─────────────────────────────────────────────
# 2. LIB STRUCTURE
# ─────────────────────────────────────────────

# core/animations
mkdir -p lib/core/animations
cat > lib/core/animations/animation_helper.dart << 'DART'
import 'package:flutter/material.dart';

class AnimationHelper {
  static Widget fadeSlide({required Widget child, required Animation<double> animation}) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }
}
DART

# core/config/env
mkdir -p lib/core/config/env
cat > lib/core/config/env/environment.dart << 'DART'
enum Environment { dev, prod }
DART

cat > lib/core/config/env/env_config.dart << 'DART'
import 'environment.dart';

abstract class EnvConfig {
  Environment get environment;
  String get baseUrl;
  String get apiKey;
}
DART

cat > lib/core/config/env/dev_env.dart << 'DART'
import 'env_config.dart';
import 'environment.dart';

class DevEnv implements EnvConfig {
  @override
  Environment get environment => Environment.dev;

  @override
  String get baseUrl => 'https://dev.api.example.com';

  @override
  String get apiKey => '';
}
DART

cat > lib/core/config/env/prod_env.dart << 'DART'
import 'env_config.dart';
import 'environment.dart';

class ProdEnv implements EnvConfig {
  @override
  Environment get environment => Environment.prod;

  @override
  String get baseUrl => 'https://api.example.com';

  @override
  String get apiKey => '';
}
DART

cat > lib/core/config/env/env.dart << 'DART'
import 'dev_env.dart';
import 'env_config.dart';

class Env {
  static EnvConfig config = DevEnv();
}
DART

# core/config/router
mkdir -p lib/core/config/router
cat > lib/core/config/router/route_names.dart << 'DART'
class RouteNames {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const home = '/home';
}
DART

cat > lib/core/config/router/auth_listenable.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthListenable extends ChangeNotifier {
  AuthListenable(Ref ref) {
    // listen to auth state and call notifyListeners()
  }
}
DART

cat > lib/core/config/router/app_router.dart << 'DART'
import 'package:go_router/go_router.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    // Define your routes here
  ],
);
DART

# core/constants — infrastructure only
mkdir -p lib/core/constants
cat > lib/core/constants/api_constants.dart << 'DART'
class ApiConstants {
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
}
DART

touch lib/core/constants/constant.dart

# core/error
mkdir -p lib/core/error
cat > lib/core/error/exception.dart << 'DART'
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}
DART

# core/firebase
mkdir -p lib/core/firebase
cat > lib/core/firebase/firebase_services.dart << 'DART'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseServices {
  static final auth = FirebaseAuth.instance;
  static final firestore = FirebaseFirestore.instance;
  static final storage = FirebaseStorage.instance;
}
DART

# core/local_storage
mkdir -p lib/core/local_storage
cat > lib/core/local_storage/local_storage_services.dart << 'DART'
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageServices {
  final SharedPreferences _prefs;
  LocalStorageServices(this._prefs);

  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, bool value) async =>
      _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> remove(String key) async => _prefs.remove(key);

  Future<void> clear() async => _prefs.clear();
}
DART

cat > lib/core/local_storage/local_storage_provider.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_services.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final localStorageProvider = Provider<LocalStorageServices>((ref) {
  return LocalStorageServices(ref.watch(sharedPreferencesProvider));
});
DART

# core/network
mkdir -p lib/core/network/interceptors
cat > lib/core/network/dio_client.dart << 'DART'
import 'package:dio/dio.dart';
import '../config/env/env.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.config.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    return dio;
  }
}
DART

cat > lib/core/network/api_services.dart << 'DART'
import 'package:dio/dio.dart';

class ApiServices {
  final Dio _dio;
  ApiServices(this._dio);

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
DART

cat > lib/core/network/network_info.dart << 'DART'
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }
}
DART

cat > lib/core/network/connectivity_notifier.dart << 'DART'
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged
      .map((result) => result.first != ConnectivityResult.none);
});
DART

cat > lib/core/network/interceptors/retry_interceptor.dart << 'DART'
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Retry logic here
    super.onError(err, handler);
  }
}
DART

# core/offline
mkdir -p lib/core/offline
cat > lib/core/offline/offline_queue_service.dart << 'DART'
import '../local_storage/local_storage_services.dart';

class OfflineQueueService {
  static const _queueKey = 'offline_queue';
  final LocalStorageServices _storage;

  OfflineQueueService(this._storage);

  void enqueue(Map<String, dynamic> action) {
    // Add action to the offline queue
  }

  List<Map<String, dynamic>> getQueue() {
    // Return pending actions
    return [];
  }

  void clearQueue() {
    _storage.remove(_queueKey);
  }
}
DART

touch lib/core/offline/offline_queue_provider.dart

# core/providers
mkdir -p lib/core/providers
cat > lib/core/providers/core_providers.dart << 'DART'
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_services.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final connectivityProvider2 = Provider<Connectivity>((ref) => Connectivity());

final dioProvider = Provider<Dio>((ref) => DioClient.create());

final apiServicesProvider = Provider<ApiServices>((ref) {
  return ApiServices(ref.watch(dioProvider));
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider2));
});
DART

# core/resources
mkdir -p lib/core/resources/assets
cat > lib/core/resources/assets/images.dart << 'DART'
class AppImages {
  static const base = 'assets/images';
  // static const logo = '$base/png/logo.png';
}
DART

cat > lib/core/resources/assets/icons.dart << 'DART'
class AppIcons {
  static const base = 'assets/icons';
  // static const home = '$base/svg/home.svg';
}
DART

# core/theme
mkdir -p lib/core/theme

# Design system tokens — belong in theme, not constants
cat > lib/core/theme/app_colors.dart << 'DART'
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const secondary = Color(0xFF10B981);
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFEF4444);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E7EB);

  // Dark
  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
}
DART

cat > lib/core/theme/app_text_styles.dart << 'DART'
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const heading2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
DART

cat > lib/core/theme/app_sizes.dart << 'DART'
class AppSizes {
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
  static const double iconS = 16;
  static const double iconM = 24;
  static const double iconL = 32;
  static const double buttonHeight = 52;
}
DART

cat > lib/core/theme/app_spacing.dart << 'DART'
import 'package:flutter/material.dart';

class AppSpacing {
  static const xs = EdgeInsets.all(4);
  static const sm = EdgeInsets.all(8);
  static const md = EdgeInsets.all(16);
  static const lg = EdgeInsets.all(24);
  static const xl = EdgeInsets.all(32);

  static const hmd = EdgeInsets.symmetric(horizontal: 16);
  static const vmd = EdgeInsets.symmetric(vertical: 16);
}
DART

cat > lib/core/theme/app_theme.dart << 'DART'
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.heading1,
        bodyMedium: AppTextStyles.body,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Inter',
    );
  }
}
DART

cat > lib/core/theme/theme_provider.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
DART

# core/utils
mkdir -p lib/core/utils
cat > lib/core/utils/app_validator.dart << 'DART'
class AppValidator {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }
}
DART

touch lib/core/utils/helper_functions.dart
touch lib/core/utils/responsive_helper.dart

# ─────────────────────────────────────────────
# 3. FEATURES SCAFFOLD FUNCTION
# ─────────────────────────────────────────────
scaffold_feature() {
  local name=$1
  local cap=$(echo "${name:0:1}" | tr '[:lower:]' '[:upper:]')${name:1}

  echo "  -> Scaffolding feature: $name"

  # domain
  mkdir -p lib/features/$name/domain/entities
  mkdir -p lib/features/$name/domain/repository
  mkdir -p lib/features/$name/domain/usecases

  # data
  mkdir -p lib/features/$name/data/datasource
  mkdir -p lib/features/$name/data/dtos/requests
  mkdir -p lib/features/$name/data/dtos/response
  mkdir -p lib/features/$name/data/models
  mkdir -p lib/features/$name/data/repository

  # presentation
  mkdir -p lib/features/$name/presentation/providers
  mkdir -p lib/features/$name/presentation/screens
  mkdir -p lib/features/$name/presentation/widgets

  # Stub files
  cat > lib/features/$name/domain/repository/${name}_repository.dart << DART
abstract class ${cap}Repository {
  // Define contracts here
}
DART

  cat > lib/features/$name/data/datasource/${name}_remote_datasource.dart << DART
abstract class ${cap}RemoteDatasource {
  // Define remote data methods here
}
DART

  cat > lib/features/$name/data/datasource/${name}_remote_datasource_impl.dart << DART
import '${name}_remote_datasource.dart';

class ${cap}RemoteDatasourceImpl implements ${cap}RemoteDatasource {
  // Implement methods here
}
DART

  cat > lib/features/$name/data/repository/${name}_repository_impl.dart << DART
import '../../domain/repository/${name}_repository.dart';

class ${cap}RepositoryImpl implements ${cap}Repository {
  // Implement repository methods here
}
DART

  cat > lib/features/$name/presentation/providers/${name}_state.dart << DART
abstract class ${cap}State {
  const ${cap}State();
}

class ${cap}Initial extends ${cap}State {}
class ${cap}Loading extends ${cap}State {}
class ${cap}Loaded extends ${cap}State {}
class ${cap}Error extends ${cap}State {
  final String message;
  const ${cap}Error(this.message);
}
DART

  cat > lib/features/$name/presentation/providers/${name}_notifier.dart << DART
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '${name}_state.dart';

class ${cap}Notifier extends StateNotifier<${cap}State> {
  ${cap}Notifier() : super(${cap}Initial());
}
DART

  cat > lib/features/$name/presentation/providers/${name}_provider.dart << DART
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '${name}_notifier.dart';
import '${name}_state.dart';

final ${name}Provider = StateNotifierProvider<${cap}Notifier, ${cap}State>((ref) {
  return ${cap}Notifier();
});
DART

  cat > lib/features/$name/presentation/screens/${name}_screen.dart << DART
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ${cap}Screen extends ConsumerWidget {
  const ${cap}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('${cap}')),
      body: const Center(child: Text('${cap} Screen')),
    );
  }
}
DART
}

# Scaffold all features
for feature in auth home wallet transaction dashboard profile; do
  scaffold_feature "$feature"
done

# ─────────────────────────────────────────────
# 4. SHARED WIDGETS
# ─────────────────────────────────────────────
mkdir -p lib/shared/widgets
mkdir -p lib/shared/modal

cat > lib/shared/widgets/app_button.dart << 'DART'
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onTap, child: _label)
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              onPressed: onTap,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : _label,
            ),
    );
  }

  Widget get _label => Text(label);
}
DART

cat > lib/shared/widgets/app_text_field.dart << 'DART'
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
      ),
    );
  }
}
DART

cat > lib/shared/widgets/app_loader.dart << 'DART'
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
DART

cat > lib/shared/widgets/skeleton_box.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
DART

cat > lib/shared/widgets/empty_state.dart << 'DART'
import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
DART

cat > lib/shared/widgets/offline_banner.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/connectivity_notifier.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    return isOnline.maybeWhen(
      data: (online) => online
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text(
                'You are offline',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
DART

touch lib/shared/widgets/app_card.dart
touch lib/shared/widgets/app_scaffold.dart
touch lib/shared/widgets/social_button.dart
touch lib/shared/modal/custom_modal.dart
touch lib/shared/modal/bottom_sheet_custom_widget.dart

# ─────────────────────────────────────────────
# 5. MAIN.DART
# ─────────────────────────────────────────────
cat > lib/main.dart << DART
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/router/app_router.dart';
import 'core/local_storage/local_storage_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: '$PROJECT_NAME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
DART

# ─────────────────────────────────────────────
# 6. PUBSPEC.YAML DEPENDENCIES NOTICE
# ─────────────────────────────────────────────
cat > DEPENDENCIES.txt << 'TXT'
Add these to your pubspec.yaml dependencies section:

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  firebase_core: ^4.4.0
  firebase_auth: ^6.1.4
  cloud_firestore: ^6.1.2
  dio: ^5.4.0
  dartz: ^0.10.1
  connectivity_plus: ^5.0.2
  shared_preferences: ^2.2.2
  animations: ^2.1.1
  flutter_animate: ^4.5.2
  firebase_storage: ^13.0.6
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0
  flutter_screenutil: ^5.9.3
  crypto: ^3.0.3
  shimmer: ^3.0.0
  fl_chart: ^1.2.0

flutter section:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/images/png/
    - assets/images/svg/
    - assets/icons/svg/
    - assets/icons/png/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter_18pt-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter_28pt-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter_28pt-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter_28pt-Bold.ttf
          weight: 700
TXT

echo ""
echo "Done! Structure created for: $PROJECT_NAME"
echo ""
echo "Next steps:"
echo "  1. Copy Inter font files into assets/fonts/"
echo "  2. Run: flutterfire configure  (to generate firebase_options.dart)"
echo "  3. Paste dependencies from DEPENDENCIES.txt into your pubspec.yaml"
echo "  4. Run: flutter pub get"
echo ""
