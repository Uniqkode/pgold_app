# PGold Wallet — Transaction Review & Report Flow

A Flutter fintech app that allows users to view wallet transactions, inspect transaction details, and report transactions.

## How to Run

```bash
flutter pub get
dart run build_runner build   # Generate MobX store files
dart run flutter_native_splash:create  # Generate native splash assets (already done)
flutter run                   # Run on connected device/emulator
flutter test                  # Run tests
```

## Packages Used

| Package | Purpose |
|---|---|
| `mobx` + `flutter_mobx` | State management — observables, actions, computed values |
| `mobx_codegen` + `build_runner` | Generate MobX boilerplate |
| `go_router` | Declarative routing with path parameters |
| `intl` | Currency (₦) and date formatting |
| `shared_preferences` | Persist reported transaction IDs across app restarts |
| `flutter_native_splash` | Native splash screen (brand color + logo before Flutter loads) |
| `mocktail` | Mocking for unit tests |
| `flutter_lints` | Code quality linting |

## Folder Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp.router with theme & stores
├── routes/
│   └── app_router.dart       # GoRouter configuration (5 routes)
├── models/
│   ├── user.dart             # User data class
│   ├── transaction.dart      # Transaction + enums + report eligibility
│   ├── report.dart           # Report + ReportReason enum
│   └── dashboard_response.dart
├── stores/                   # MobX stores
│   ├── dashboard_store.dart  # User + transactions, loading/error/empty
│   ├── transaction_detail_store.dart
│   ├── report_store.dart     # Form state + validation + submission
│   └── pin_store.dart        # PIN entry + verification + lockout + PinStoreManager
├── services/
│   ├── api_result.dart       # Sealed class: Success<T> / Failure<T>
│   ├── api_service.dart      # Abstract API contract
│   ├── mock_api_service.dart # Simulated backend with delays & failures
│   └── report_persistence_service.dart  # SharedPreferences persistence
├── screens/
│   ├── splash_screen.dart    # Animated logo splash → dashboard
│   ├── dashboard_screen.dart # Wallet header + recent transactions + staggered animations
│   ├── transfer_history_screen.dart  # Full history sorted by Today/Yesterday/Month
│   ├── transaction_detail_screen.dart
│   └── report_screen.dart
├── widgets/
│   ├── wallet_header.dart    # Balance card with hide/show toggle
│   ├── transaction_card.dart
│   ├── status_badge.dart
│   ├── loading_widget.dart
│   ├── error_widget.dart
│   ├── empty_state_widget.dart
│   ├── pin_keypad.dart       # Custom numeric keypad
│   ├── pin_entry_view.dart   # Self-contained PIN entry panel
│   └── pin_dialog.dart       # Dialog wrapper for PIN entry
└── utils/
    ├── colors.dart           # Centralized AppColors constants
    ├── formatters.dart       # Currency, date, date-group formatting
    └── constants.dart
```

## MobX State Management

Four separate stores, each with focused responsibilities:

**DashboardStore** — `user`, `transactions`, `isLoading`, `error`, `isEmpty` (computed). Fetches dashboard data on init, supports pull-to-refresh.

**TransactionDetailStore** — `transaction`, `isLoading`, `error`, `canReport` (computed), `reportBlockedReason` (computed). Loads single transaction, local `markAsReported()` for instant UI update.

**ReportStore** — `selectedReason`, `description`, `isSubmitting`, `submissionError`, `submittedReport`. Form validation computeds (`isFormValid`, `descriptionError`, `descriptionCharCount`). Reset after success/failure.

**PinStore** — `pinDigits`, `attempts`, `isLocked`, `isVerifying`, `verificationError`, `isVerified`, `canAttempt` (computed), `remainingAttempts` (computed). Actions: `addDigit()`, `removeDigit()`, `verifyPin()`, `clearEntry()`, `reset()`.

**PinStoreManager** — Singleton that holds a shared PinStore instance for the app session, preserving lockout state across dialog opens/closes.

Business logic stays in stores and models — widgets only observe and render.

## Simulated Backend / Mock Service

`MockApiService` implements `ApiService` and:
- Embeds 14 mock transactions with dates spanning May–July 2026
- Adds artificial delays (1s for dashboard/report, 500ms for single txn/PIN)
- Simulates failures: dashboard load failure, transaction not found, duplicate report, wrong PIN
- Enforces business rules at the service layer: failed/reversed txns rejected, duplicate reports blocked
- Test PIN is `1234`
- Integrates with `ReportPersistenceService` to persist reported IDs via SharedPreferences

## Routes

| Path | Screen | Description |
|---|---|---|
| `/splash` | SplashScreen | Logo fade-in/out → auto-navigates to dashboard |
| `/dashboard` | DashboardScreen | Wallet balance, recent 3 txns, greeting island, View All |
| `/transfer-history` | TransferHistoryScreen | All transactions grouped by Today/Yesterday/Month |
| `/transaction-details/:id` | TransactionDetailScreen | Full txn details, report eligibility, report button |
| `/report-transaction/:id` | ReportScreen | Report form with reason dropdown + description + PIN confirm |

## Validation

- **Report reason**: required (dropdown selection)
- **Description**: required, 20–250 characters, real-time character count
- Real-time validation via ReportStore computed properties
- Submit button disabled until `isFormValid` is true
- Double-submit prevented by `isSubmitting` flag

## PIN Flow

1. User fills report form and taps Submit
2. PinDialog opens with PinEntryView:
   - Custom numeric keypad (no system keyboard — prevents keylogging)
   - 4 obscured dot indicators with shake animation on wrong PIN
   - Auto-verifies when 4 digits entered
3. PinStore tracks attempts (max 3 before session lockout)
4. On lockout: dialog auto-closes → restricted dialog appears with lock icon
5. Lockout persists for entire app session via PinStoreManager singleton
6. PIN state (`pinDigits`) cleared after success, failure, or cancel
7. No debugPrint/logging of PIN values ever
8. Report success shows dialog with checkmark + friendly message


## Dev Drawer — Simulating Edge Cases

A developer drawer is available from the dashboard (hamburger icon in the AppBar) to test edge cases without modifying code:

| Toggle | What it does |
|---|---|
| **Empty Transactions** | Dashboard shows wallet header + inline empty state. Tap again to restore transactions. |
| **Dashboard Error** | Next dashboard load returns a server error (full-screen error with retry). The toggle resets after the failure. |
| **Transaction Not Found** | Tapping any transaction card shows the "not found" error screen. Toggle off to restore normal behavior. |

Toggle a simulation on, then refresh or navigate to test the corresponding UI state.

## Edge Cases Handled

- Empty transaction list → EmptyStateWidget
- Dashboard load error → ErrorWidget with retry
- Transaction not found → 404-style error with retry
- Failed/reversed txn → report button hidden, blocked reason shown
- Already reported txn → blocked with message, caution icon shown
- Form invalid → submit disabled
- Wrong PIN → error shown, attempts tracked
- 3 wrong PIN attempts → soft lock for session, restricted dialog
- Double-tap submit → `isSubmitting` flag prevents duplicate
- Successful report → success dialog, local state updated
- Back-navigation after report → transaction shows active report
- Dashboard limit → only 3 most recent shown, View All for full history

## Tests

33 tests across 4 test files:

- `transaction_eligibility_test.dart` — `canBeReported` logic for all status/report combinations, `copyWith`
- `report_form_validation_test.dart` — form validation, submit flow, double-submit prevention, API error handling, reset
- `pin_verification_test.dart` — digit entry, PIN verification, wrong PIN, 3-attempt lockout, incomplete PIN, reset
- `widget_test.dart` — smoke test

## Known Trade-offs

- **No DI framework**: Stores are created manually in screens. A package like `provider` or `get_it` would scale better.
- **No widget tests**: Only unit tests. Widget/integration tests would verify UI behavior.
- **Mock data is embedded**: Not loaded from JSON asset at runtime, which simplifies testing but is less realistic.

## What I'd Improve With More Time

1. Add widget tests for all screens (loading, error, empty, data states)
2. Add integration test for the full report flow
3. Use `provider` or `riverpod` for cleaner dependency injection
4. Add biometric auth as a faster PIN alternative
5. Add pagination for large transaction lists
6. Add dark mode support
7. Add CI pipeline (GitHub Actions) for automated testing
8. Localize strings for i18n support
9. Animated transitions between screens
