// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pocketflow/core/config/env/env_config.dart';
import 'package:pocketflow/core/config/router/app_router.dart';
import 'package:pocketflow/core/enums/environment.dart';
import 'package:pocketflow/core/local_storage/local_storage_services.dart';
import 'package:pocketflow/core/theme/app_theme.dart';
import 'package:pocketflow/core/utils/responsive_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPrefs = await SharedPreferences.getInstance();
  // await FirebaseFirestore.instance.enablePersistence(
  //   const PersistenceSettings(synchronizeTabs: true),
  // );
  await EnvConfig.init(
    environment: Environment.dev, // change to prod when needed
  );
  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(
          LocalStorageService(sharedPrefs),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final themeMode = ref.watch(themeProvider);
    // final router = ref.watch(routerProvider);
    return ScreenUtilInit(
      designSize: getSizeForDevice(context),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: EnvConfig.instance.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
