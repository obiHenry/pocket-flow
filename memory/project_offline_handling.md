---
name: Offline Handling Implementation
description: Summary of the offline handling layer added to PocketFlow — what was built, how it works, and what's pending
type: project
---

Offline handling phase completed. Four pillars implemented:

1. **Detect offline** — `lib/core/network/connectivity_notifier.dart` exports `isOnlineProvider` (StreamProvider<bool>) using `connectivity_plus` v5 (single `ConnectivityResult` return, not a list).

2. **Read cached data** — `LocalStorageService` gained raw-JSON cache methods for transactions (`cacheTransactionsRaw`/`getCachedTransactionsRaw` keyed by uid) and user (`cacheUserRaw`/`getCachedUserRaw`). `TransactionNotifier._fetchFirstPage()` reads cache when offline; `UserNotifier._fetchUser()` reads cache when offline. Both write to cache after every successful online fetch.

3. **Queue actions** — `lib/core/offline/offline_queue_service.dart` + `offline_queue_provider.dart`. `OfflineQueueService` stores pending ops in SharedPreferences under key `offline_action_queue`. On offline add: temp transaction with id `offline_{timestamp}` is prepended to local state and params are queued. On reconnect (`isOnlineProvider` emits true after false): `_flushQueue()` removes the temp placeholder and calls `_addTransactionOnServer()`. Delete/edit return an error message when offline (not queued — simple version decision).

4. **Offline banner** — `lib/shared/widgets/offline_banner.dart` (`OfflineBanner`). Mounted in `DashboardPage` body (Column wrapping the Row) so it appears on all dashboard tabs.

**`main.dart`** overrides both `localStorageProvider` and `offlineQueueProvider` with `SharedPreferences` instances.

**`TransactionModel`** and **`UserModel`** (profile) both have `toJson()`/`fromJson()` added for local cache serialization. `UserModel.fromMap` was preserved as a delegate to the renamed `UserModel.from` factory to keep datasource compatibility.

**Why:** exchange rates were already cached (60-min TTL); we extended that pattern to transactions and user data, adding a write queue for the most common offline action (adding transactions).
