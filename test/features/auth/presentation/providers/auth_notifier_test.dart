// ============================================================
// IMPORTS
// ============================================================

// Core Flutter testing library —
// gives us test(), group(), expect(), setUp()
import 'package:flutter_test/flutter_test.dart';

// mocktail lets us create fake versions of our repository
// so we never touch real Firebase during tests
import 'package:mocktail/mocktail.dart';

// dartz gives us Either, Right, Left —
// Right = success, Left = failure (AppException in your case)
import 'package:dartz/dartz.dart';

// Firebase needed because AppException.fromFirebaseAuth
// takes a FirebaseAuthException — used in the exception tests
import 'package:firebase_auth/firebase_auth.dart';

// Your actual classes
import 'package:pocketflow/features/auth/domain/repository/auth_repository.dart';
import 'package:pocketflow/features/auth/presentation/providers/auth_notifier.dart';
import 'package:pocketflow/features/auth/presentation/providers/auth_state.dart';
import 'package:pocketflow/features/auth/domain/entities/app_user.dart';
import 'package:pocketflow/core/error/exception.dart';

// ============================================================
// MOCK CLASS
// ============================================================

// This creates a fake version of your AuthRepository.
// "extends Mock" — gives mocktail control over it so we can
// tell it exactly what to return using when().thenAnswer()
// "implements AuthRepository" — ensures it has all the same
// method signatures as your real repository
class MockAuthRepository extends Mock implements AuthRepository {}

// ============================================================
// FAKE USER
// ============================================================

// A real AppUser instance used as fake data throughout tests.
// Simulates what Firebase would return on successful auth.
// We define it once here and reuse across all test groups.
const fakeUser = AppUser(
  uid: 'test-uid-123',
  email: 'henry@test.com',
  displayName: 'Henry Obi',
  isEmailVerified: true,
  photoUrl: null,
  phoneNumber: null,
);

// ============================================================
// MAIN
// ============================================================

void main() {
  // Declared here so every group() and test() below can access them
  late MockAuthRepository mockRepo;
  late AuthNotifier notifier;

  // setUp() runs before EACH individual test automatically.
  // This guarantees every test starts completely fresh —
  // no state or mock configuration bleeds between tests.
  setUp(() {
    mockRepo = MockAuthRepository(); // brand new mock each test
    notifier = AuthNotifier(mockRepo); // brand new notifier each test
  });

  // ============================================================
  // GROUP 1: LOGIN
  // ============================================================

  group('AuthNotifier - login', () {
    test('should emit loading then authenticated on success', () async {
      // ---- ARRANGE ----
      // Tell the mock: when login() is called with these exact values,
      // return Right(fakeUser) — simulating Firebase accepting the login
      when(
        () => mockRepo.login(email: 'henry@test.com', password: 'password123'),
      ).thenAnswer(
        // thenAnswer is for async methods that return a Future
        (_) async => const Right(fakeUser),
      );

      // ---- ACT ----
      // Call the real notifier method — same code your UI triggers
      await notifier.login('henry@test.com', 'password123');

      // ---- ASSERT ----
      // Based on your notifier's fold right side:
      // state = state.copyWith(status: AuthStatus.authenticated, user: user)
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(
        notifier.state.user,
        fakeUser, // user should be attached to state
      );
      expect(
        notifier.state.errorMessage,
        isNull, // no error on success
      );
    });

    test(
      'should emit loading status immediately when login is called',
      () async {
        // ---- ARRANGE ----
        // Add a delay so we can catch the intermediate loading state
        // before the future resolves
        when(
          () => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {
          // Simulate network delay
          await Future.delayed(const Duration(milliseconds: 100));
          return const Right(fakeUser);
        });

        // ---- ACT ----
        // Do NOT await — we want to check state mid-execution
        // before the repository call completes
        final loginFuture = notifier.login('henry@test.com', 'password123');

        // ---- ASSERT ----
        // Your notifier sets loading immediately before calling repository:
        // state = state.copyWith(status: AuthStatus.loading,
        //                        loadingAction: AuthLoadingAction.login)
        expect(notifier.state.status, AuthStatus.loading);
        expect(notifier.state.loadingAction, AuthLoadingAction.login);

        // Now finish the future so setUp cleanup works cleanly
        await loginFuture;
      },
    );

    test('should emit error with message when login fails', () async {
      // ---- ARRANGE ----
      // any(named: 'email') means "match whatever value is passed as email"
      // useful when we don't care about the specific value,
      // just that the method returns a failure
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        // Left = failure. AppException instead of Failure since
        // that's your actual setup — Either<AppException, T>
        (_) async => Left(AppException('Invalid credentials')),
      );

      // ---- ACT ----
      await notifier.login('wrong@email.com', 'wrongpass');

      // ---- ASSERT ----
      // Your notifier's fold left side:
      // state = state.copyWith(status: AuthStatus.error,
      //                        errorMessage: failure.message)
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.errorMessage, 'Invalid credentials');
      expect(notifier.state.user, isNull); // no user on failure
    });
  });

  // ============================================================
  // GROUP 2: SIGN UP
  // ============================================================

  group('AuthNotifier - signUp', () {
    test('should emit authenticated after successful signup', () async {
      // ---- ARRANGE ----
      // signUp in your notifier makes 3 repository calls:
      // 1. signUp() — creates Firebase Auth account
      // 2. updateUserProfile() — sets display name  } both called
      // 3. createUserProfile() — writes to Firestore } via Future.wait

      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(fakeUser));

      when(
        () => mockRepo.updateUserProfile(
          userId: any(named: 'userId'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => mockRepo.createUserProfile(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          displayName: any(named: 'displayName'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      // ---- ACT ----
      await notifier.signUp(
        name: 'Henry Obi',
        email: 'henry@test.com',
        password: 'password123',
      );

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user, fakeUser);
      // No profile errors so errorMessage should be null
      expect(notifier.state.errorMessage, isNull);
    });

    test('should emit error when Firebase account creation fails', () async {
      // ---- ARRANGE ----
      when(
        () => mockRepo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Left(AppException('Email already in use')));

      // ---- ACT ----
      await notifier.signUp(
        name: 'Henry Obi',
        email: 'taken@test.com',
        password: 'password123',
      );

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.errorMessage, 'Email already in use');
    });

    test(
      'should still authenticate even when Firestore profile write fails',
      () async {
        // This tests your specific design decision:
        // "Always authenticate — profile write failures are non-blocking"
        // Even if Firestore is down, user still gets logged in.

        // ---- ARRANGE ----
        when(
          () => mockRepo.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Right(fakeUser));

        when(
          () => mockRepo.updateUserProfile(
            userId: any(named: 'userId'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => const Right(unit));

        // Firestore write fails — simulating it being down
        when(
          () => mockRepo.createUserProfile(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => Left(AppException('Firestore unavailable')));

        // ---- ACT ----
        await notifier.signUp(
          name: 'Henry Obi',
          email: 'henry@test.com',
          password: 'password123',
        );

        // ---- ASSERT ----
        // User IS authenticated despite Firestore failure —
        // your notifier's design explicitly handles this case
        expect(notifier.state.status, AuthStatus.authenticated);
        expect(notifier.state.user, fakeUser);
        // But errorMessage IS set so UI can show a warning snackbar
        expect(notifier.state.errorMessage, 'Firestore unavailable');
      },
    );
  });

  // ============================================================
  // GROUP 3: GOOGLE SIGN IN
  // ============================================================

  group('AuthNotifier - signInWithGoogle', () {
    test('should emit authenticated on successful Google sign in', () async {
      // ---- ARRANGE ----
      when(
        () => mockRepo.signInWithGoogle(),
      ).thenAnswer((_) async => const Right(fakeUser));

      // ---- ACT ----
      await notifier.signInWithGoogle();

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user, fakeUser);
    });

    test(
      'should emit loading with google action when Google sign in starts',
      () async {
        // ---- ARRANGE ----
        when(() => mockRepo.signInWithGoogle()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const Right(fakeUser);
        });

        // ---- ACT ----
        // Don't await — catch the loading state mid-execution
        final future = notifier.signInWithGoogle();

        // ---- ASSERT ----
        // Your notifier sets loadingAction: AuthLoadingAction.google
        // so the UI knows to show the Google-specific loading indicator
        expect(notifier.state.status, AuthStatus.loading);
        expect(notifier.state.loadingAction, AuthLoadingAction.google);

        await future;
      },
    );

    test(
      'should emit error when Google sign in is cancelled or fails',
      () async {
        // ---- ARRANGE ----
        when(() => mockRepo.signInWithGoogle()).thenAnswer(
          (_) async => Left(AppException('Google sign in cancelled')),
        );

        // ---- ACT ----
        await notifier.signInWithGoogle();

        // ---- ASSERT ----
        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.errorMessage, 'Google sign in cancelled');
      },
    );
  });

  // ============================================================
  // GROUP 4: APPLE SIGN IN
  // ============================================================

  group('AuthNotifier - signInWithApple', () {
    test('should emit authenticated on successful Apple sign in', () async {
      // ---- ARRANGE ----
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => const Right(fakeUser));

      // ---- ACT ----
      await notifier.signInWithApple();

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user, fakeUser);
    });

    test('should emit error when Apple sign in fails', () async {
      // ---- ARRANGE ----
      when(
        () => mockRepo.signInWithApple(),
      ).thenAnswer((_) async => Left(AppException('Apple sign in failed')));

      // ---- ACT ----
      await notifier.signInWithApple();

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.errorMessage, 'Apple sign in failed');
    });
  });

  // ============================================================
  // GROUP 5: LOGOUT
  // ============================================================

  group('AuthNotifier - logout', () {
    test('should emit unauthenticated on successful logout', () async {
      // ---- ARRANGE ----
      when(() => mockRepo.logout()).thenAnswer((_) async => const Right(unit));

      // ---- ACT ----
      await notifier.logout();

      // ---- ASSERT ----
      // Your notifier's fold right side:
      // state = state.copyWith(status: AuthStatus.unauthenticated)
      expect(notifier.state.status, AuthStatus.unauthenticated);
    });

    test('should emit loading with logout action when logout starts', () async {
      // ---- ARRANGE ----
      when(() => mockRepo.logout()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Right(unit);
      });

      // ---- ACT ----
      final future = notifier.logout();

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.loading);
      expect(notifier.state.loadingAction, AuthLoadingAction.logout);

      await future;
    });

    test('should emit error when logout fails', () async {
      // ---- ARRANGE ----
      when(
        () => mockRepo.logout(),
      ).thenAnswer((_) async => Left(AppException('Logout failed')));

      // ---- ACT ----
      await notifier.logout();

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.errorMessage, 'Logout failed');
    });
  });

  // ============================================================
  // GROUP 6: CHECK SESSION
  // ============================================================

  group('AuthNotifier - checkSession', () {
    test('should emit authenticated when active session exists', () async {
      // ---- ARRANGE ----
      // Right(fakeUser) — Firebase confirms user is logged in
      when(
        () => mockRepo.getCurrentUser(),
      ).thenAnswer((_) async => const Right(fakeUser));

      // ---- ACT ----
      await notifier.checkSession();

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.authenticated);
      expect(notifier.state.user, fakeUser);
    });

    test(
      'should emit unauthenticated when no session exists (null user)',
      () async {
        // ---- ARRANGE ----
        // Right(null) means the Firebase call SUCCEEDED but no one
        // is logged in — different from a failure/error
        when(
          () => mockRepo.getCurrentUser(),
        ).thenAnswer((_) async => const Right(null));

        // ---- ACT ----
        await notifier.checkSession();

        // ---- ASSERT ----
        // Your notifier checks: if (user != null) → authenticated
        //                        else → unauthenticated
        expect(notifier.state.status, AuthStatus.unauthenticated);
      },
    );

    test('should emit unauthenticated when session check fails', () async {
      // ---- ARRANGE ----
      // Left = actual error — network down, Firebase error, etc.
      when(
        () => mockRepo.getCurrentUser(),
      ).thenAnswer((_) async => Left(AppException('Session check failed')));

      // ---- ACT ----
      await notifier.checkSession();

      // ---- ASSERT ----
      // Your notifier treats both null user AND failure
      // the same way — unauthenticated
      expect(notifier.state.status, AuthStatus.unauthenticated);
    });
  });

  // ============================================================
  // GROUP 7: FORGOT PASSWORD
  // ============================================================

  group('AuthNotifier - forgotPassword', () {
    test(
      'should emit initial status when reset email sent successfully',
      () async {
        // ---- ARRANGE ----
        when(
          () => mockRepo.resetPassword(email: any(named: 'email')),
        ).thenAnswer((_) async => Right(unit));

        // ---- ACT ----
        await notifier.forgotPassword('henry@test.com');

        // ---- ASSERT ----
        // Your notifier sets status back to initial on success —
        // meaning "email sent, no error, not loading"
        expect(notifier.state.status, AuthStatus.initial);
      },
    );

    test('should emit error when reset password fails', () async {
      // ---- ARRANGE ----
      when(
        () => mockRepo.resetPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => Left(AppException('Email not found')));

      // ---- ACT ----
      await notifier.forgotPassword('notfound@test.com');

      // ---- ASSERT ----
      expect(notifier.state.status, AuthStatus.error);
      expect(notifier.state.errorMessage, 'Email not found');
    });
  });

  // ============================================================
  // GROUP 8: APP EXCEPTION TESTS
  // ============================================================
  // These test your AppException class directly — pure unit tests,
  // no notifier or mock needed. This is your core error handling
  // infrastructure so it's worth testing separately.

  group('AppException - fromFirebaseAuth', () {
    test('should return correct message for wrong-password code', () {
      // ---- ARRANGE ----
      // Create a real FirebaseAuthException with a specific code
      final e = FirebaseAuthException(code: 'wrong-password');

      // ---- ACT ----
      final exception = AppException.fromFirebaseAuth(e);

      // ---- ASSERT ----
      // Based on your switch statement:
      // 'wrong-password' → 'Incorrect password.'
      expect(exception.message, 'Incorrect password.');
      expect(exception.code, 'wrong-password');
    });

    test('should return network message for network-request-failed', () {
      final e = FirebaseAuthException(code: 'network-request-failed');
      final exception = AppException.fromFirebaseAuth(e);

      expect(
        exception.message,
        'No internet connection. Check your network and try again.',
      );
    });

    test('should return correct message for email-already-in-use', () {
      final e = FirebaseAuthException(code: 'email-already-in-use');
      final exception = AppException.fromFirebaseAuth(e);

      expect(exception.message, 'An account with this email already exists.');
    });

    test('should return correct message for too-many-requests', () {
      final e = FirebaseAuthException(code: 'too-many-requests');
      final exception = AppException.fromFirebaseAuth(e);

      expect(exception.message, 'Too many attempts. Please try again later.');
    });

    test('should fall through to e.message for unknown error codes', () {
      // Tests the _ (default) case in your switch statement
      final e = FirebaseAuthException(
        code: 'some-unknown-code',
        // This is what the _ case returns: e.message ?? 'Authentication error.'
        message: 'Something unexpected happened',
      );
      final exception = AppException.fromFirebaseAuth(e);

      expect(exception.message, 'Something unexpected happened');
    });

    test(
      'should return Authentication error when unknown code has null message',
      () {
        // Tests the ?? fallback: e.message ?? 'Authentication error.'
        final e = FirebaseAuthException(
          code: 'unknown-code',
          message: null, // no message provided
        );
        final exception = AppException.fromFirebaseAuth(e);

        expect(exception.message, 'Authentication error.');
      },
    );

    test('should return same AppException if already an AppException', () {
      // Tests the guard: if (e is AppException) return e
      // Prevents double-wrapping exceptions
      final original = AppException('Already wrapped');
      final result = AppException.fromFirebaseAuth(original);

      // same() checks it's the identical object in memory, not just equal
      expect(result, same(original));
    });
  });
}
