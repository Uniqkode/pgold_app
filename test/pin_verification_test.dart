import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/services/api_result.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/pin_store.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReportReason.other);
  });

  late MockApiService apiService;
  late PinStore store;

  setUp(() {
    apiService = MockApiService();
    store = PinStore(apiService);
  });

  group('PinStore initial state', () {
    test('starts with empty pin, zero attempts, not locked, not verified', () {
      expect(store.pinLength, 0);
      expect(store.pinDigits, isEmpty);
      expect(store.attempts, 0);
      expect(store.isLocked, isFalse);
      expect(store.isVerified, isFalse);
      expect(store.isVerifying, isFalse);
      expect(store.verificationError, isNull);
      expect(store.canAttempt, isTrue);
      expect(store.remainingAttempts, 3);
    });
  });

  group('PinStore digit entry', () {
    test('addDigit appends digits up to 4', () {
      store.addDigit('1');
      expect(store.pinLength, 1);
      expect(store.pinDigits, '1');

      store.addDigit('2');
      store.addDigit('3');
      store.addDigit('4');
      expect(store.pinLength, 4);
      expect(store.pinDigits, '1234');
    });

    test('addDigit ignores digits after 4', () {
      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3');
      store.addDigit('4');
      store.addDigit('5');

      expect(store.pinLength, 4);
      expect(store.pinDigits, '1234');
    });

    test('removeDigit removes last digit', () {
      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3');

      store.removeDigit();
      expect(store.pinDigits, '12');
      expect(store.pinLength, 2);

      store.removeDigit();
      store.removeDigit();
      expect(store.pinDigits, isEmpty);
      expect(store.pinLength, 0);
    });

    test('removeDigit on empty does nothing', () {
      store.removeDigit();
      expect(store.pinDigits, isEmpty);
    });

    test('addDigit clears verification error when pin is not full', () {
      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3'); // 3 digits, not full
      store.verificationError = 'Wrong PIN';

      store.addDigit('4'); // now 4 digits, should have cleared error
      expect(store.verificationError, isNull);
    });
  });

  group('PinStore PIN verification', () {
    test('verifyPin with correct PIN succeeds', () async {
      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3');
      store.addDigit('4');

      when(() => apiService.verifyTransactionPin('1234'))
          .thenAnswer((_) async => const Success(null));

      await store.verifyPin();

      expect(store.isVerified, isTrue);
      expect(store.isVerifying, isFalse);
      expect(store.pinDigits, isEmpty);
      expect(store.verificationError, isNull);
    });

    test('verifyPin with wrong PIN increments attempts', () async {
      store.addDigit('1');
      store.addDigit('1');
      store.addDigit('1');
      store.addDigit('1');

      when(() => apiService.verifyTransactionPin('1111'))
          .thenAnswer((_) async => const Failure('Incorrect PIN.'));

      await store.verifyPin();

      expect(store.isVerified, isFalse);
      expect(store.attempts, 1);
      expect(store.verificationError, isNotNull);
      expect(store.pinDigits, isEmpty);
    });

    test('three wrong attempts cause lockout', () async {
      when(() => apiService.verifyTransactionPin(any()))
          .thenAnswer((_) async => const Failure('Incorrect PIN.'));

      for (var i = 0; i < 3; i++) {
        store.addDigit('1');
        store.addDigit('1');
        store.addDigit('1');
        store.addDigit('1');
        await store.verifyPin();
      }

      expect(store.isLocked, isTrue);
      expect(store.remainingAttempts, 0);
      expect(store.canAttempt, isFalse);

      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3');
      store.addDigit('4');

      await store.verifyPin();

      verifyNever(() => apiService.verifyTransactionPin('1234'));
    });

    test('verifyPin with incomplete PIN does nothing', () async {
      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3');

      await store.verifyPin();

      verifyNever(() => apiService.verifyTransactionPin(any()));
      expect(store.isVerifying, isFalse);
    });
  });

  group('PinStore reset', () {
    test('reset clears all state', () {
      store.addDigit('1');
      store.addDigit('2');
      store.addDigit('3');
      store.addDigit('4');
      store.attempts = 2;
      store.verificationError = 'Some error';

      store.reset();

      expect(store.pinDigits, isEmpty);
      expect(store.pinLength, 0);
      expect(store.attempts, 0);
      expect(store.isLocked, isFalse);
      expect(store.isVerified, isFalse);
      expect(store.isVerifying, isFalse);
      expect(store.verificationError, isNull);
    });
  });
}
