# PGold Wallet — Transaction Review & Report Flow

A Flutter fintech app that allows users to view wallet transactions, inspect transaction details, and report transactions.

## How to Run

```bash
flutter pub get
dart run build_runner build   # Generate MobX store files
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
| `mocktail` | Mocking for unit tests |
| `flutter_lints` | Code quality linting |

## Folder Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp.router with theme & stores
├── routes/
│   └── app_router.dart       # GoRouter configuration (3 routes)
├── models/
│   ├── user.dart             # User data class
│   ├── transaction.dart      # Transaction + enums + report eligibility
│   ├── report.dart           # Report + ReportReason enum
│   └── dashboard_response.dart
├── stores/                   # MobX stores
│   ├── dashboard_store.dart  # User + transactions, loading/error/empty
│   ├── transaction_detail_store.dart
│   ├── report_store.dart     # Form state + validation + submission
│   └── pin_store.dart        # PIN entry + verification + lockout
├── services/
│   ├── api_result.dart       # Sealed class: Success<T> / Failure<T>
│   ├── api_service.dart      # Abstract API contract
│   └── mock_api_service.dart # Simulated backend with delays & failures
├── screens/
│   ├── dashboard_screen.dart
│   ├── transaction_detail_screen.dart
│   └── report_screen.dart
├── widgets/
│   ├── wallet_header.dart
│   ├── transaction_card.dart
│   ├── status_badge.dart
│   ├── loading_widget.dart
│   ├── error_widget.dart
│   ├── empty_state_widget.dart
│   ├── pin_keypad.dart
│   ├── pin_entry_view.dart
│   └── pin_dialog.dart
└── utils/
    ├── formatters.dart
    └── constants.dart
```

## MobX State Management

Four separate stores, each with focused responsibilities:

**DashboardStore** — `user`, `transactions`, `isLoading`, `error`, `isEmpty` (computed). Fetches dashboard data on init, supports pull-to-refresh.

**TransactionDetailStore** — `transaction`, `isLoading`, `error`, `canReport` (computed), `reportBlockedReason` (computed). Loads single transaction, local `markAsReported()` for instant UI update.

**ReportStore** — `selectedReason`, `description`, `isSubmitting`, `submissionError`, `submittedReport`. Form validation computeds (`isFormValid`, `descriptionError`, `descriptionCharCount`). Reset after success/failure.

**PinStore** — `pinDigits`, `attempts`, `isLocked`, `isVerifying`, `verificationError`, `isVerified`, `canAttempt` (computed), `remainingAttempts` (computed). Actions: `addDigit()`, `removeDigit()`, `verifyPin()`, `reset()`.

Business logic stays in stores and models — widgets only observe and render.

## Simulated Backend / Mock Service

`MockApiService` implements `ApiService` and:
- Embeds mock user & transaction data from the assignment spec
- Adds artificial delays (1s for dashboard/report, 500ms for single txn/PIN)
- Simulates failures: dashboard load failure, transaction not found, duplicate report, wrong PIN
- Enforces business rules at the service layer: failed/reversed txns rejected, duplicate reports blocked
- Test PIN is `1234`

## Validation

- **Report reason**: required (dropdown selection)
- **Description**: required, 20–250 characters
- Real-time validation via ReportStore computed properties
- Submit button disabled until `isFormValid` is true
- Double-submit prevented by `isSubmitting` flag

## PIN Flow

1. User fills report form and taps Submit
2. PinDialog opens with PinEntryView:
   - Custom numeric keypad (no system keyboard — prevents keylogging)
   - 4 obscured dot indicators
   - Auto-verifies when 4 digits entered
   - Shake animation on wrong PIN
3. PinStore tracks attempts (max 3 before session lockout)
4. PIN state (`pinDigits`) is cleared after success, failure, or cancel
5. No debugPrint/logging of PIN values ever

## Edge Cases Handled

- Empty transaction list → EmptyStateWidget
- Dashboard load error → ErrorWidget with retry
- Transaction not found → 404-style error with retry
- Failed/reversed txn → report button hidden, blocked reason shown
- Already reported txn → blocked with message
- Form invalid → submit disabled
- Wrong PIN → error shown, attempts tracked
- 3 wrong PIN attempts → soft lock for session
- Double-tap submit → `isSubmitting` flag prevents duplicate
- Successful report → local state updated, success snackbar
- Back-navigation after report → transaction shows active report

## Tests

33 tests across 4 test files:

- `transaction_eligibility_test.dart` — `canBeReported` logic for all status/report combinations
- `report_form_validation_test.dart` — form validation, submit flow, double-submit prevention, API error handling
- `pin_verification_test.dart` — digit entry, PIN verification, wrong PIN, 3-attempt lockout, reset
- `widget_test.dart` — smoke test

## Known Trade-offs

- **No persistence**: Report state resets on app restart. SharedPreferences or Hive would add this.
- **Mock service uses in-memory state**: Reported transaction IDs are tracked in a Set, lost on restart.
- **No DI framework**: Stores are created manually in screens. A package like `provider` or `get_it` would scale better.
- **PIN lockout is session-only**: Resets when the app restarts. Production would persist this server-side.
- **No widget tests**: Only unit tests. Widget/integration tests would verify UI behavior.

## What I'd Improve With More Time

1. Persist report state with Hive or SharedPreferences
2. Add widget tests for all screens (loading, error, empty, data states)
3. Add integration test for the full report flow
4. Use `provider` or `riverpod` for cleaner dependency injection
5. Add biometric auth as a faster PIN alternative
6. Add pull-to-refresh to the detail screen
7. Add pagination for large transaction lists
8. Add dark mode support
9. Extract a shared theme configuration file
10. Add CI pipeline (GitHub Actions) for automated testing
