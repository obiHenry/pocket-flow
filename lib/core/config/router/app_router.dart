import 'package:go_router/go_router.dart';
import 'package:pocketflow/core/config/router/route_names.dart';
import 'package:pocketflow/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:pocketflow/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:pocketflow/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:pocketflow/features/auth/presentation/screens/splash_screen.dart';
import 'package:pocketflow/features/dashboard/presentation/screens/dashboard_page.dart';
import 'package:pocketflow/features/transaction/presentation/screens/transaction_screen.dart';

import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../animations/animation_helper.dart';

// import '../../../features/auth/presentation/pages/login_page.dart';
// import '../../../features/home/presentation/pages/home_page.dart';
// import '../../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) =>
            AnimationHelper.fade(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) =>
            AnimationHelper.fade(state: state, child: OnboardingScreen()),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        pageBuilder: (context, state) =>
            AnimationHelper.fade(state: state, child: SignInScreen()),
      ),
      GoRoute(
        path: RouteNames.signUp,
        name: RouteNames.signUp,
        pageBuilder: (context, state) =>
            AnimationHelper.fade(state: state, child: SignUpScreen()),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) =>
            AnimationHelper.fade(state: state, child: ForgotPasswordScreen()),
      ),

      ShellRoute(
        builder: (context, state, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            name: RouteNames.home,
            path: RouteNames.home,
            pageBuilder: (context, state) =>
                AnimationHelper.fade(state: state, child: const HomeScreen()),
          ),
          GoRoute(
            name: RouteNames.wallet,
            path: RouteNames.wallet,
            pageBuilder: (context, state) =>
                AnimationHelper.fade(state: state, child: const WalletScreen()),
          ),
          GoRoute(
            name: RouteNames.profile,
            path: RouteNames.profile,
            pageBuilder: (context, state) => AnimationHelper.fade(
              state: state,
              child: const ProfileScreen(),
            ),
          ),

          GoRoute(
            name: RouteNames.transaction,
            path: RouteNames.transaction,
            pageBuilder: (context, state) => AnimationHelper.fade(
              state: state,
              child: const TransactionsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authStreamProvider);
//   final localService = ref.read(localServiceProvider);

//   return GoRouter(
//     initialLocation: RouteNames.splash,

//     // This tells GoRouter to re-run the redirect logic whenever
//     // the Auth Stream emits a new value (Login/Logout).
//     refreshListenable: AuthRefreshListenable(ref),

//     redirect: (context, state) {
//       // 1. Capture the current Auth and Onboarding status
//       final bool isLoggedIn = authState.value != null;
//       final bool hasSeenOnboarding = localService.getOnboardingStatus();

//       // 2. Identify the current location to prevent infinite loops
//       final String location = state.matchedLocation;
//       final bool isGoingToSplash = location == RouteNames.splash;
//       final bool isGoingToOnboarding = location == RouteNames.onboarding;
//       final bool isGoingToAuth =
//           location == RouteNames.login || location == RouteNames.signUp;

//       // --- GUARD LOGIC ---

//       // A. Handle Splash: Determine where to send the user on cold boot
//       if (isGoingToSplash) {
//         if (!hasSeenOnboarding) return RouteNames.onboarding;
//         return isLoggedIn ? RouteNames.dashboard : RouteNames.login;
//       }

//       // B. Protection: If not logged in and not on an Auth/Onboarding page, force Login
//       if (!isLoggedIn && !isGoingToAuth && !isGoingToOnboarding) {
//         return RouteNames.login;
//       }

//       // C. Redundancy: If logged in, don't allow access to Login/Onboarding/SignUp
//       if (isLoggedIn && (isGoingToAuth || isGoingToOnboarding)) {
//         return RouteNames.dashboard;
//       }

//       // D. Allow the navigation
//       return null;
//     },

//     routes: [
//       GoRoute(
//         path: RouteNames.splash,
//         name: RouteNames.splash,
//         pageBuilder: (context, state) =>
//             AnimationHelper.fade(state: state, child: const SplashScreen()),
//       ),
//       GoRoute(
//         path: RouteNames.onboarding,
//         name: RouteNames.onboarding,
//         pageBuilder: (context, state) =>
//             AnimationHelper.fade(state: state, child: OnboardingScreen()),
//       ),
//       GoRoute(
//         path: RouteNames.login,
//         name: RouteNames.login,
//         pageBuilder: (context, state) =>
//             AnimationHelper.fade(state: state, child: SignInScreen()),
//       ),
//       GoRoute(
//         path: RouteNames.signUp,
//         name: RouteNames.signUp,
//         pageBuilder: (context, state) =>
//             AnimationHelper.fade(state: state, child: SignUpScreen()),
//       ),
//       GoRoute(
//         path: RouteNames.forgotPassword,
//         name: RouteNames.forgotPassword,
//         pageBuilder: (context, state) =>
//             AnimationHelper.fade(state: state, child: ForgotPasswordScreen()),
//       ),
//       GoRoute(
//         path: RouteNames.dashboard,
//         name: RouteNames.dashboard,
//         pageBuilder: (context, state) =>
//             AnimationHelper.fade(state: state, child: const DashboardPage()),
//       ),
//     ],
//   );
// });
// // }
