# PocketFlow

A full-stack personal finance tracker built with Flutter and Firebase. Tracks income and expenses, shows live exchange rates, supports offline use, and adapts its layout to mobile, tablet, and desktop — all from a single codebase.

Built to demonstrate production-grade Flutter architecture for a technical interview.

---

## Screens & Features

### Authentication
| Screen | What it does |
|---|---|
| **Splash** | Bootstraps session, routes to onboarding / login / home |
| **Onboarding** | 3-page PageView carousel (Track, Insights, Security) — shown once, status persisted to SharedPreferences |
| **Login** | Email/password + Google + Apple Sign-In |
| **Sign Up** | Name/email/password + social signup |
| **Forgot Password** | Firebase password reset via email |

### Main App (Dashboard Shell)
The authenticated shell uses GoRouter's `ShellRoute`. On mobile it renders a hamburger drawer; on tablet/desktop a permanent 280 px sidebar — no platform channel, just `MediaQuery` breakpoints.

| Screen | What it does |
|---|---|
| **Home** | Balance card (NGN + USD), quick actions, weekly expense bar chart, recent transactions, live currency ticker in the SliverAppBar |
| **Wallet** | Card stack with balance and monthly stats, asset allocation pie chart, transaction activity list |
| **Transactions** | Paginated list with search, filter chips (All / Income / Expense / category), add/edit/delete sheets; desktop shows a sortable table with prev/next pagination |
| **Profile** | Avatar, account settings, dark mode toggle, currency preference, export CSV, delete account |

### Cross-cutting
- **Offline banner** — slides in across all tabs when connectivity is lost
- **Dark mode** — system-aware with manual override, persisted across sessions
- **Skeleton / shimmer loading** — every screen has a loading state; no blank flashes
- **Responsive layout** — single codebase adapts across phone, tablet, and desktop

---

## Tech Stack

| Concern | Package | Decision rationale |
|---|---|---|
| State management | `flutter_riverpod 2.x` | `AsyncNotifier` keeps actions and state on the same object; compile-safe; no `BuildContext` in business logic |
| Navigation | `go_router 13` | Declarative, deep-link ready, `ShellRoute` for the bottom nav shell |
| Backend | Firebase Auth + Firestore | Auth, real-time DB, and storage in one SDK |
| HTTP | `dio 5` + retry interceptor | Structured error handling, timeout config, automatic retry on transient failures |
| Local cache | `shared_preferences` | Lightweight persistence for rates, user, transactions, and offline queue |
| Error handling | `dartz` `Either<L, R>` | Railway-oriented flow — every repository method forces the caller to handle both success and failure |
| Connectivity | `connectivity_plus 5` | Live network stream for offline detection |
| Charts | `fl_chart` | Bar chart (expenses), pie chart (asset allocation) |
| Responsive | `flutter_screenutil` | sp / dp scaling for consistent sizing across screen densities |
| Loading states | `shimmer` | Skeleton shimmer on every async screen |

---

## Architecture

Clean Architecture with a **feature-first** folder structure. Each feature owns its data, domain, and presentation layers and is fully self-contained.

```
lib/
├── core/
│   ├── network/            # Dio client, retry interceptor, connectivity notifier
│   ├── offline/            # OfflineQueueService (SharedPreferences-backed write queue)
│   ├── local_storage/      # SharedPreferences wrapper + raw JSON cache helpers
│   ├── firebase/           # Abstract Firebase base service (Auth, Firestore, Storage)
│   ├── error/              # AppException + DioException / FirebaseException mappers
│   ├── theme/              # ThemeNotifier, AppTheme (light + dark)
│   ├── animations/         # AnimationHelper (fadeInSlide, fade, scale)
│   ├── constants/          # Colors, text styles, spacing
│   ├── config/             # EnvConfig (API keys), GoRouter, route guards
│   └── providers/          # Global Riverpod providers (Dio, Connectivity)
│
└── features/
    └── <feature>/
        ├── data/
        │   ├── datasource/   # Firebase / Dio calls — returns Either<AppException, T>
        │   ├── models/       # Dart models with toFirebase / toJson / fromJson
        │   └── repository/   # Implements domain interface; wraps datasource
        ├── domain/
        │   ├── entities/     # Pure Dart; zero framework dependencies
        │   └── repository/   # Abstract contract consumed by notifiers
        └── presentation/
            ├── providers/    # AsyncNotifier (or StateNotifier) + Provider declarations
            ├── screens/      # Full-page ConsumerWidget
            └── widgets/      # Composable ConsumerWidget pieces
```

### Data flow — adding a transaction

```
TransactionSheet (UI)
  └── ref.read(transactionProvider.notifier).addTransaction(...)
        │
        ├─ [offline] ──► _queueAdd()
        │                  ├── Prepend temp placeholder to local state (immediate UI feedback)
        │                  └── Persist params to OfflineQueueService
        │
        └─ [online] ───► _addTransactionOnServer()
                           ├── _repo.addTransaction()      → Firestore write
                           └── userProvider.updateUser()   → Firestore balance update
                                 ├── Optimistic state update (instant UI)
                                 └── Rollback on Firestore error
```

### Error handling path

Every datasource method returns `Either<AppException, T>`. The repository passes it through. The notifier calls `.fold(left, right)` — the compiler forces handling of both branches. Silent failures are structurally impossible.

---

## State Management

### Why `AsyncNotifier` over `FutureProvider` + `StateProvider`

`FutureProvider` is read-only. `AsyncNotifier` keeps the async data **and** its mutation methods (`addTransaction`, `deleteTransaction`, etc.) on a single object. No need for a parallel `StateNotifier` to trigger actions or a global `ref.refresh()` to invalidate.

### `autoDispose` — applied per-feature, not globally

| Provider | `autoDispose`? | Reason |
|---|---|---|
| `walletProvider` | ✅ | Screen-scoped; releasing it avoids stale mock data between visits |
| `exchangeRateProvider` | ✅ | Re-init is essentially free — `_fetchRates()` returns the 60-min SharedPreferences cache before touching the network |
| `transactionProvider` | ❌ | Shared by the home tab (recent list) and transactions tab (full paginated list). Disposing would discard the Firestore pagination cursor, the in-memory offline queue, and the session write-through cache |
| `userProvider` | ❌ | Global; drives balance on every screen |
| `isOnlineProvider` | ❌ | A continuous stream — auto-disposing it would miss connectivity changes mid-session |
| `themeProvider`, `authNotifierProvider` | ❌ | Full session lifetime |

### Optimistic updates with rollback

`UserNotifier.updateUser()` writes the new `UserModel` to Riverpod state immediately, fires the Firestore call, and on error restores the previous snapshot. Balance changes feel instant with no loading spinner.

---

## Offline Handling

Zero new dependencies — built entirely on the existing `connectivity_plus` + `SharedPreferences` stack.

### Detect
`isOnlineProvider` (`StreamProvider<bool>`) emits an initial value from `checkConnectivity()` then follows `onConnectivityChanged`. No `AsyncLoading` gap at startup.

### Cache reads
| Data | Key | Written | Offline behaviour |
|---|---|---|---|
| Exchange rates | `cached_exchange_rates` | Every fresh API call | Returned as-is; 60-min TTL check skipped |
| Transactions | `cached_tx_{uid}` | Every successful Firestore page | Full last-known list shown |
| User / balance | `cached_user` | Every successful Firestore user fetch | Cached `UserModel` served |

### Queue writes
`OfflineQueueService` stores a JSON array under `offline_action_queue`. Each add-transaction item stores a `tempId` (matching the optimistic placeholder in UI state) and the original form params.

`TransactionNotifier` uses `ref.listen(isOnlineProvider, ...)` inside `build()`. On `false → true`: removes the placeholder, calls `_addTransactionOnServer()`, and clears the queue item on success.

Delete and edit are blocked offline with a user-facing message (v1 intentional — avoids conflict resolution complexity).

### Banner
`OfflineBanner` lives in `DashboardPage` (the GoRouter shell) — one widget covers all tabs. `AnimatedSwitcher` + `SizeTransition` give it a smooth slide-in/out.

---

## Key Engineering Decisions

**No `BuildContext` in business logic.**
All Firestore, Auth, and HTTP calls live inside Riverpod notifiers. Any notifier can be unit-tested with a fake repository — no widget tree needed.

**Single SharedPreferences instance, injected at startup.**
Created once in `main()`, passed to both `LocalStorageService` and `OfflineQueueService` via `ProviderScope.overrides`. Cache logic is testable with Flutter's `SharedPreferences.setMockInitialValues`.

**`Either<AppException, T>` at every layer boundary.**
Forces error handling at the call site. The notifier `.fold()` must handle both paths — a pattern borrowed from functional programming that makes omitted error handling a compile error, not a runtime surprise.

**Retry interceptor on Dio.**
Transient network errors are retried transparently before an `AppException` reaches the UI.

**Responsive without platform channels.**
`DashboardPage` renders sidebar vs. drawer based on `MediaQuery` breakpoints. `ProfileScreen` switches between a `ListView` and a two-column `SliverGrid`. Nothing in the responsive code is platform-specific.

---

## Setup

**Prerequisites:** Flutter 3.x, a Firebase project with Auth + Firestore enabled, an exchange rate API key.

```bash
# 1. Clone
git clone <repo-url> && cd pocketflow

# 2. Install
flutter pub get

# 3. Configure Firebase
flutterfire configure
# This generates lib/firebase_options.dart and drops the
# platform config files into android/ and ios/

# 4. Run
flutter run
```

Environment variables (API base URL, keys) are managed via `EnvConfig` in `lib/core/config/env/`.

---

## Project Status

| Area | Status |
|---|---|
| Authentication (email, Google, Apple) | ✅ Complete |
| Transaction CRUD + balance sync | ✅ Complete |
| Exchange rates (cached) | ✅ Complete |
| Offline read + write queue | ✅ Complete |
| Dark mode | ✅ Complete |
| Responsive layout | ✅ Complete |
| Wallet (real data) | 🚧 Mock — pending API integration |
| Push notifications | 📋 Planned |
| Biometric lock | 📋 Planned |
| CSV export | 📋 Planned |
| Unit + widget tests | 📋 Planned |
