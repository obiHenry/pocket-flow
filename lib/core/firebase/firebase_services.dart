import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../error/exception.dart';

/// Abstract base class for all Firebase services.
/// It provides generic methods for interacting with Firebase services
/// (Auth, Firestore, Storage) and handles common error mapping using AppException.
abstract class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  static const _kTimeout = Duration(seconds: 10);

  // Runs [call] with an optional timeout. Pass timeout: null for file uploads
  // where duration depends on file size. All other calls default to 10 seconds.
  // Network errors surface through the Firebase SDK's own error codes, which
  // onError maps to readable AppExceptions — no unreliable pre-check needed.
  Future<Either<AppException, T>> _run<T>({
    required Future<T> Function() call,
    required AppException Function(dynamic e) onError,
    Duration? timeout = _kTimeout,
  }) async {
    try {
      final future = call();
      return Right(await (timeout != null ? future.timeout(timeout) : future));
    } on TimeoutException {
      return Left(
        AppException(
          'Request timed out. Check your connection and try again.',
          code: 'timeout',
        ),
      );
    } catch (e) {
      return Left(onError(e));
    }
  }

  // ============================
  // AUTH OPERATIONS
  // ============================

  /// Sign in with email and password
  Future<Either<AppException, T>> signIn<T>({
    required String email,
    required String password,
    required T Function(UserCredential credential) parser,
  }) => _run(
    call: () async {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return parser(result);
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Register a new user with email and password
  Future<Either<AppException, T>> register<T>({
    required String email,
    required String password,
    required T Function(UserCredential credential) parser,
  }) => _run(
    call: () async {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return parser(result);
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Sign out the current user
  Future<Either<AppException, Unit>> logout() => _run(
    call: () async {
      await _auth.signOut();
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Get the current authenticated user — reads from local cache, no network call.
  Future<Either<AppException, T>> getCurrentUser<T>({
    required T Function(User? user) parser,
  }) async {
    try {
      return Right(parser(_auth.currentUser));
    } catch (e) {
      return Left(AppException.fromFirebaseAuth(e));
    }
  }

  /// Send password reset email
  Future<Either<AppException, Unit>> sendPasswordResetEmail({
    required String email,
  }) => _run(
    call: () async {
      await _auth.sendPasswordResetEmail(email: email);
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Update user profile display name / photo in Firebase Auth
  Future<Either<AppException, Unit>> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) throw AppException('No user logged in');
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Send email verification to the current user
  Future<Either<AppException, Unit>> verifyEmail() => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) throw AppException('No user logged in');
      await user.sendEmailVerification();
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Send email verification (alias for verifyEmail)
  Future<Either<AppException, Unit>> sendEmailVerification() => verifyEmail();

  /// Reload the Auth user and check email verification status
  Future<Either<AppException, bool>> checkEmailVerified() => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Sign in with Google OAuth
  Future<Either<AppException, T>> signInWithGoogle<T>({
    required T Function(UserCredential credential) parser,
  }) => _run(
    call: () async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw AppException('Google sign in cancelled');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return parser(await _auth.signInWithCredential(credential));
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Sign in with Apple OAuth
  Future<Either<AppException, T>> signInWithApple<T>({
    required T Function(UserCredential credential) parser,
  }) => _run(
    call: () async {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
      return parser(await _auth.signInWithCredential(oauthCredential));
    },
    onError: AppException.fromFirebaseAuth,
  );

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Facebook OAuth
  ///
  /// [parser]: Function to parse the UserCredential into AppUser
  // Future<Either<AppException, T>> signInWithFacebook<T>({
  //   required T Function(UserCredential credential) parser,
  // }) async {
  //   try {
  //     // Trigger the sign-in flow
  //     final LoginResult loginResult = await FacebookAuth.instance.login();

  //     if (loginResult.status != LoginStatus.success) {
  //       return Left(AppException.fromUnknown('Facebook sign in failed'));
  //     }

  //     // Create a credential from the access token
  //     final OAuthCredential facebookAuthCredential =
  //         FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

  //     // Sign in to Firebase with the Facebook credential
  //     final userCredential = await _auth.signInWithCredential(
  //       facebookAuthCredential,
  //     );

  //     return Right(parser(userCredential));
  //   } catch (e) {
  //     return Left(AppException.fromFirebaseAuth(e));
  //   }
  // }

  /// Delete the current user's Firebase Auth account
  Future<Either<AppException, Unit>> deleteAccount() => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) throw AppException('No user logged in');
      await user.delete();
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Reauthenticate the current user with their password
  Future<Either<AppException, Unit>> reauthenticate({
    required String password,
  }) => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) throw AppException('No user logged in');
      if (user.email == null) throw AppException('User email not found');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Send a verification email before updating the user's email address
  Future<Either<AppException, Unit>> updateEmail({required String newEmail}) =>
      _run(
        call: () async {
          final user = _auth.currentUser;
          if (user == null) throw AppException('No user logged in');
          await user.verifyBeforeUpdateEmail(newEmail);
          return unit;
        },
        onError: AppException.fromFirebaseAuth,
      );

  /// Update the user's password
  Future<Either<AppException, Unit>> updatePassword({
    required String newPassword,
  }) => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) throw AppException('No user logged in');
      await user.updatePassword(newPassword);
      return unit;
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Link an email/password credential to the current user
  Future<Either<AppException, T>> linkEmailPassword<T>({
    required String email,
    required String password,
    required T Function(UserCredential credential) parser,
  }) => _run(
    call: () async {
      final user = _auth.currentUser;
      if (user == null) throw AppException('No user logged in');
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      return parser(await user.linkWithCredential(credential));
    },
    onError: AppException.fromFirebaseAuth,
  );

  /// Listen to authentication state changes
  ///
  /// Returns a stream of User (null when logged out)
  Stream<User?> watchAuthState() {
    return _auth.authStateChanges();
  }

  // ============================
  // FIRESTORE - CREATE
  // ============================

  /// Create a new document in a collection
  Future<Either<AppException, T>> createDocument<T>({
    required String collection,
    required Map<String, dynamic> data,
    required T Function(String docId) parser,
  }) => _run(
    call: () async {
      final doc = await _firestore.collection(collection).add(data);
      return parser(doc.id);
    },
    onError: AppException.fromFirestore,
  );

  /// Set a document with a specific ID
  Future<Either<AppException, Unit>> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) => _run(
    call: () async {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
      return unit;
    },
    onError: AppException.fromFirestore,
  );

  // ============================
  // FIRESTORE - READ
  // ============================

  /// Get a document by ID
  Future<Either<AppException, T>> getDocumentById<T>({
    required String collection,
    required String docId,
    required T Function(Map<String, dynamic>? data) parser,
  }) => _run(
    call: () async {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return parser(doc.data());
    },
    onError: AppException.fromFirestore,
  );

  /// Fetch all documents from a collection
  Future<Either<AppException, T>> fetchCollection<T>({
    required String collection,
    required T Function(List<Map<String, dynamic>> data) parser,
  }) => _run(
    call: () async {
      final snapshot = await _firestore.collection(collection).get();
      return parser(snapshot.docs.map((e) => e.data()).toList());
    },
    onError: AppException.fromFirestore,
  );

  /// Fetch a paginated page of documents ordered by [orderByField].
  ///
  /// Pass [startAfter] (the last DocumentSnapshot from the previous page) to
  /// get the next page. On the first page, omit it or pass null.
  Future<
    Either<
      AppException,
      ({List<Map<String, dynamic>> docs, DocumentSnapshot? lastDoc})
    >
  >
  fetchCollectionPaginated({
    required String collection,
    required int limit,
    DocumentSnapshot? startAfter,
    String orderByField = 'date',
    bool descending = true,
  }) => _run(
    call: () async {
      Query<Map<String, dynamic>> query = _firestore
          .collection(collection)
          .orderBy(orderByField, descending: descending)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs.map((e) => e.data()).toList();
      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return (docs: docs, lastDoc: lastDoc);
    },
    onError: AppException.fromFirestore,
  );

  /// Fetch documents with a query
  Future<Either<AppException, T>> queryCollection<T>({
    required String collection,
    required Query<Map<String, dynamic>> Function(
      CollectionReference<Map<String, dynamic>> ref,
    )
    queryBuilder,
    required T Function(List<Map<String, dynamic>> data) parser,
  }) => _run(
    call: () async {
      final query = queryBuilder(_firestore.collection(collection));
      final snapshot = await query.get();
      return parser(snapshot.docs.map((e) => e.data()).toList());
    },
    onError: AppException.fromFirestore,
  );

  // ============================
  // FIRESTORE - UPDATE
  // ============================

  /// Update a document
  Future<Either<AppException, Unit>> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) => _run(
    call: () async {
      await _firestore.collection(collection).doc(docId).update(data);
      return unit;
    },
    onError: AppException.fromFirestore,
  );

  // ============================
  // FIRESTORE - DELETE
  // ============================

  /// Delete a document
  Future<Either<AppException, Unit>> deleteDocument({
    required String collection,
    required String docId,
  }) => _run(
    call: () async {
      await _firestore.collection(collection).doc(docId).delete();
      return unit;
    },
    onError: AppException.fromFirestore,
  );

  // ============================
  // STORAGE - UPLOAD
  // ============================

  // Uploads skip the timeout because duration depends on file size.
  // They still get the connectivity pre-check via timeout: null.

  /// Upload a file to Firebase Storage
  Future<Either<AppException, T>> uploadFile<T>({
    required File file,
    required String path,
    required T Function(String downloadUrl) parser,
    Function(double progress)? onProgress,
  }) => _run(
    timeout: null,
    call: () async {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        });
      }
      await uploadTask;
      return parser(await ref.getDownloadURL());
    },
    onError: AppException.fromStorage,
  );

  /// Upload multiple files to Firebase Storage
  Future<Either<AppException, T>> uploadFiles<T>({
    required List<File> files,
    required String Function(int index, File file) pathBuilder,
    required T Function(List<String> downloadUrls) parser,
    Function(double progress)? onProgress,
  }) => _run(
    timeout: null,
    call: () async {
      final urls = <String>[];
      for (int i = 0; i < files.length; i++) {
        final ref = _storage.ref().child(pathBuilder(i, files[i]));
        await ref.putFile(files[i]);
        urls.add(await ref.getDownloadURL());
        onProgress?.call((i + 1) / files.length);
      }
      return parser(urls);
    },
    onError: AppException.fromStorage,
  );

  // ============================
  // STORAGE - DELETE
  // ============================

  /// Delete a file from Firebase Storage
  Future<Either<AppException, Unit>> deleteFile({required String path}) => _run(
    call: () async {
      await _storage.ref().child(path).delete();
      return unit;
    },
    onError: AppException.fromStorage,
  );

  /// Delete a file using its download URL
  Future<Either<AppException, Unit>> deleteFileByUrl({required String url}) =>
      _run(
        call: () async {
          await _storage.refFromURL(url).delete();
          return unit;
        },
        onError: AppException.fromStorage,
      );

  // ============================
  // STORAGE - GET
  // ============================

  /// Get the download URL for a file
  Future<Either<AppException, T>> getFileUrl<T>({
    required String path,
    required T Function(String url) parser,
  }) => _run(
    call: () async => parser(await _storage.ref().child(path).getDownloadURL()),
    onError: AppException.fromStorage,
  );

  /// Get file metadata
  Future<Either<AppException, T>> getFileMetadata<T>({
    required String path,
    required T Function(FullMetadata metadata) parser,
  }) => _run(
    call: () async => parser(await _storage.ref().child(path).getMetadata()),
    onError: AppException.fromStorage,
  );
}
