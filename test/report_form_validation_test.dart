import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/services/api_result.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/report_store.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReportReason.other);
  });

  late MockApiService apiService;
  late ReportStore store;

  setUp(() {
    apiService = MockApiService();
    store = ReportStore(apiService);
  });

  group('ReportStore form validation', () {
    test('initial state has invalid form', () {
      expect(store.isFormValid, isFalse);
      expect(store.selectedReason, isNull);
      expect(store.description, isEmpty);
      expect(store.descriptionCharCount, 0);
      expect(store.descriptionError, isNull);
    });

    test('setting reason without description keeps form invalid', () {
      store.setReason(ReportReason.erroneousTransfer);
      expect(store.isFormValid, isFalse);
      expect(store.selectedReason, ReportReason.erroneousTransfer);
    });

    test('short description shows error', () {
      store.setDescription('Short');
      expect(store.descriptionError, contains('at least 20'));
      expect(store.isFormValid, isFalse);
    });

    test('description with exactly 20 chars is valid', () {
      store.setDescription('A' * 20);
      expect(store.descriptionError, isNull);
    });

    test('description with 250 chars is valid', () {
      store.setDescription('A' * 250);
      expect(store.descriptionError, isNull);
      expect(store.descriptionCharCount, 250);
    });

    test('description exceeding 250 chars shows error', () {
      store.setDescription('A' * 251);
      expect(store.descriptionError, contains('250'));
      expect(store.isFormValid, isFalse);
    });

    test('form is valid with reason and valid description', () {
      store.setReason(ReportReason.wrongAmount);
      store.setDescription('This transaction has the wrong amount charged.');
      expect(store.isFormValid, isTrue);
      expect(store.descriptionError, isNull);
    });

    test('form validity changes reactively', () {
      expect(store.isFormValid, isFalse);

      store.setReason(ReportReason.duplicateTransaction);
      expect(store.isFormValid, isFalse);

      store.setDescription('A valid description with enough characters.');
      expect(store.isFormValid, isTrue);

      store.setReason(ReportReason.other);
      expect(store.isFormValid, isTrue);
    });
  });

  group('ReportStore submit', () {
    test('submit is blocked when form is invalid', () async {
      await store.submitReport('txn_001');

      verifyNever(() => apiService.submitTransactionReport(
            transactionId: any(named: 'transactionId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
          ));
    });

    test('submit prevents double submission', () async {
      store.setReason(ReportReason.suspectedFraud);
      store.setDescription('This looks like a fraudulent transaction.');

      when(() => apiService.submitTransactionReport(
            transactionId: any(named: 'transactionId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => Success(
            Report(
              id: 'rpt_001',
              transactionId: 'txn_001',
              reason: ReportReason.suspectedFraud,
              description: 'This looks like a fraudulent transaction.',
              date: '2026-07-09T12:00:00Z',
            ),
          ));

      final future1 = store.submitReport('txn_001');
      final future2 = store.submitReport('txn_001');

      await Future.wait([future1, future2]);

      verify(() => apiService.submitTransactionReport(
            transactionId: any(named: 'transactionId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
          )).called(1);
    });

    test('submit sets submittedReport after success', () async {
      store.setReason(ReportReason.wrongAmount);
      store.setDescription('The amount charged is incorrect.');

      when(() => apiService.submitTransactionReport(
            transactionId: any(named: 'transactionId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => Success(
            Report(
              id: 'rpt_002',
              transactionId: 'txn_001',
              reason: ReportReason.wrongAmount,
              description: 'The amount charged is incorrect.',
              date: '2026-07-09T12:00:00Z',
            ),
          ));

      await store.submitReport('txn_001');

      expect(store.submittedReport, isNotNull);
      expect(store.isSubmitting, isFalse);
    });

    test('submit handles API failure', () async {
      store.setReason(ReportReason.other);
      store.setDescription('A valid description for the report.');

      when(() => apiService.submitTransactionReport(
            transactionId: any(named: 'transactionId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => const Failure('Server error'));

      await store.submitReport('txn_001');

      expect(store.submittedReport, isNull);
      expect(store.submissionError, contains('Server error'));
      expect(store.isSubmitting, isFalse);
    });
  });

  group('ReportStore reset', () {
    test('reset clears all state', () {
      store.setReason(ReportReason.erroneousTransfer);
      store.setDescription('A description with enough characters.');

      store.reset();

      expect(store.selectedReason, isNull);
      expect(store.description, isEmpty);
      expect(store.isSubmitting, isFalse);
      expect(store.submissionError, isNull);
      expect(store.submittedReport, isNull);
    });
  });
}
