import 'package:flutter_test/flutter_test.dart';
import 'package:pgold_app/models/transaction.dart';

void main() {
  group('Transaction.canBeReported', () {
    Transaction baseTxn({
      TransactionStatus status = TransactionStatus.successful,
      bool hasActiveReport = false,
    }) {
      return Transaction(
        id: 'txn_001',
        reference: 'PG-TEST-001',
        title: 'Test Transaction',
        amount: 1000,
        fee: 0,
        type: TransactionType.walletFunding,
        status: status,
        direction: TransactionDirection.credit,
        description: 'Test description',
        date: '2026-07-07T10:30:00Z',
        hasActiveReport: hasActiveReport,
      );
    }

    test('successful transaction without report is reportable', () {
      final txn = baseTxn();
      expect(txn.canBeReported, isTrue);
      expect(txn.reportBlockedReason, isNull);
    });

    test('pending transaction without report is reportable', () {
      final txn = baseTxn(status: TransactionStatus.pending);
      expect(txn.canBeReported, isTrue);
      expect(txn.reportBlockedReason, isNull);
    });

    test('failed transaction cannot be reported', () {
      final txn = baseTxn(status: TransactionStatus.failed);
      expect(txn.canBeReported, isFalse);
      expect(txn.reportBlockedReason, contains('failed'));
    });

    test('reversed transaction cannot be reported', () {
      final txn = baseTxn(status: TransactionStatus.reversed);
      expect(txn.canBeReported, isFalse);
      expect(txn.reportBlockedReason, contains('reversed'));
    });

    test('transaction with active report cannot be reported', () {
      final txn = baseTxn(hasActiveReport: true);
      expect(txn.canBeReported, isFalse);
      expect(txn.reportBlockedReason, contains('active report'));
    });

    test('failed transaction with active report cannot be reported', () {
      final txn = baseTxn(
        status: TransactionStatus.failed,
        hasActiveReport: true,
      );
      expect(txn.canBeReported, isFalse);
      expect(txn.reportBlockedReason, contains('active report'));
    });
  });

  group('Transaction.copyWith', () {
    test('creates a copy with updated fields', () {
      final original = Transaction(
        id: 'txn_001',
        reference: 'PG-TEST-001',
        title: 'Original',
        amount: 1000,
        fee: 0,
        type: TransactionType.walletFunding,
        status: TransactionStatus.successful,
        direction: TransactionDirection.credit,
        description: 'Original',
        date: '2026-07-07T10:30:00Z',
        hasActiveReport: false,
      );

      final updated = original.copyWith(hasActiveReport: true);

      expect(updated.id, original.id);
      expect(updated.hasActiveReport, isTrue);
    });

    test('copyWith returns same instance when no arguments', () {
      final txn = Transaction(
        id: 'txn_001',
        reference: 'PG-TEST-001',
        title: 'Test',
        amount: 1000,
        fee: 0,
        type: TransactionType.walletFunding,
        status: TransactionStatus.successful,
        direction: TransactionDirection.credit,
        description: 'Test',
        date: '2026-07-07T10:30:00Z',
        hasActiveReport: false,
      );

      final copy = txn.copyWith();
      expect(copy.id, txn.id);
      expect(copy.hasActiveReport, txn.hasActiveReport);
    });
  });
}
