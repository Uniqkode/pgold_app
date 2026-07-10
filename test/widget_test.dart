import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/screens/report_screen.dart';
import 'package:pgold_app/services/api_result.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/pin_store.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReportReason.other);
  });

  late MockApiService apiService;

  setUp(() {
    apiService = MockApiService();
    PinStoreManager.dispose();
  });

  tearDown(() {
    PinStoreManager.dispose();
  });

  Widget buildTestWidget(GoRouter router) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('Success flow: enters correct PIN and shows success dialog', (tester) async {
    // 1. Mock API responses
    when(() => apiService.verifyTransactionPin(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => apiService.submitTransactionReport(
          transactionId: any(named: 'transactionId'),
          reason: any(named: 'reason'),
          description: any(named: 'description'),
        )).thenAnswer((_) async => Success(Report(
              id: 'rpt_001',
              transactionId: 'txn_123',
              reason: ReportReason.suspectedFraud,
              description: 'This is a description that is long enough.',
              date: DateTime.now().toIso8601String(),
            )));

    // 2. Setup GoRouter with a pushed route structure
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/detail',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/report'),
                child: const Text('Go to Report'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/report',
          builder: (context, state) => ReportScreen(
            transactionId: 'txn_123',
            apiService: apiService,
          ),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Scaffold(body: Text('Dashboard')),
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(router));
    await tester.pumpAndSettle();

    // Go to Report Screen
    await tester.tap(find.text('Go to Report'));
    await tester.pumpAndSettle();

    // 3. Fill form
    // Select reason
    await tester.tap(find.byType(DropdownButtonFormField<ReportReason>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ReportReason.suspectedFraud.displayName).last);
    await tester.pumpAndSettle();

    // Enter description
    await tester.enterText(
      find.byType(TextField),
      'This is a description that is long enough.',
    );
    await tester.pumpAndSettle();

    // 4. Click Submit
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    // PIN Dialog should be visible
    expect(find.text('Enter PIN'), findsOneWidget);

    // Enter 1-2-3-4
    for (var digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    // Wait for the async verification and dialog transitions
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify dialog for success is shown
    expect(find.text('Report Submitted'), findsOneWidget);
  });

  testWidgets('Locked flow: enters wrong PIN 3 times, shows restricted dialog and does not close automatically', (tester) async {
    // 1. Mock API responses to fail PIN verification
    when(() => apiService.verifyTransactionPin(any()))
        .thenAnswer((_) async => const Failure('Incorrect PIN. Please try again.'));

    // 2. Setup GoRouter with a pushed route structure
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/detail',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/report'),
                child: const Text('Go to Report'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/report',
          builder: (context, state) => ReportScreen(
            transactionId: 'txn_123',
            apiService: apiService,
          ),
        ),
      ],
    );

    await tester.pumpWidget(buildTestWidget(router));
    await tester.pumpAndSettle();

    // Go to Report Screen
    await tester.tap(find.text('Go to Report'));
    await tester.pumpAndSettle();

    // 3. Fill form
    await tester.tap(find.byType(DropdownButtonFormField<ReportReason>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ReportReason.suspectedFraud.displayName).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'This is a description that is long enough.',
    );
    await tester.pumpAndSettle();

    // 4. Click Submit
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();

    // PIN Dialog should be visible
    expect(find.text('Enter PIN'), findsOneWidget);

    // First attempt
    for (var digit in ['1', '1', '1', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('2 attempt(s) remaining'), findsOneWidget);

    // Second attempt
    for (var digit in ['1', '1', '1', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('1 attempt(s) remaining'), findsOneWidget);

    // Third attempt
    for (var digit in ['1', '1', '1', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Restricted dialog should show up
    expect(find.text('Access Restricted'), findsOneWidget);

    // Wait extra frames to make sure it doesn't close automatically
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Check if the restricted dialog is still visible
    expect(find.text('Access Restricted'), findsOneWidget);
  });
}
