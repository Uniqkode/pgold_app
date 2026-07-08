// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PinStore on _PinStore, Store {
  Computed<bool>? _$isLockedComputed;

  @override
  bool get isLocked => (_$isLockedComputed ??= Computed<bool>(
    () => super.isLocked,
    name: '_PinStore.isLocked',
  )).value;
  Computed<int>? _$remainingAttemptsComputed;

  @override
  int get remainingAttempts => (_$remainingAttemptsComputed ??= Computed<int>(
    () => super.remainingAttempts,
    name: '_PinStore.remainingAttempts',
  )).value;
  Computed<int>? _$pinLengthComputed;

  @override
  int get pinLength => (_$pinLengthComputed ??= Computed<int>(
    () => super.pinLength,
    name: '_PinStore.pinLength',
  )).value;
  Computed<bool>? _$canAttemptComputed;

  @override
  bool get canAttempt => (_$canAttemptComputed ??= Computed<bool>(
    () => super.canAttempt,
    name: '_PinStore.canAttempt',
  )).value;

  late final _$pinDigitsAtom = Atom(
    name: '_PinStore.pinDigits',
    context: context,
  );

  @override
  String get pinDigits {
    _$pinDigitsAtom.reportRead();
    return super.pinDigits;
  }

  @override
  set pinDigits(String value) {
    _$pinDigitsAtom.reportWrite(value, super.pinDigits, () {
      super.pinDigits = value;
    });
  }

  late final _$attemptsAtom = Atom(
    name: '_PinStore.attempts',
    context: context,
  );

  @override
  int get attempts {
    _$attemptsAtom.reportRead();
    return super.attempts;
  }

  @override
  set attempts(int value) {
    _$attemptsAtom.reportWrite(value, super.attempts, () {
      super.attempts = value;
    });
  }

  late final _$isVerifyingAtom = Atom(
    name: '_PinStore.isVerifying',
    context: context,
  );

  @override
  bool get isVerifying {
    _$isVerifyingAtom.reportRead();
    return super.isVerifying;
  }

  @override
  set isVerifying(bool value) {
    _$isVerifyingAtom.reportWrite(value, super.isVerifying, () {
      super.isVerifying = value;
    });
  }

  late final _$verificationErrorAtom = Atom(
    name: '_PinStore.verificationError',
    context: context,
  );

  @override
  String? get verificationError {
    _$verificationErrorAtom.reportRead();
    return super.verificationError;
  }

  @override
  set verificationError(String? value) {
    _$verificationErrorAtom.reportWrite(value, super.verificationError, () {
      super.verificationError = value;
    });
  }

  late final _$isVerifiedAtom = Atom(
    name: '_PinStore.isVerified',
    context: context,
  );

  @override
  bool get isVerified {
    _$isVerifiedAtom.reportRead();
    return super.isVerified;
  }

  @override
  set isVerified(bool value) {
    _$isVerifiedAtom.reportWrite(value, super.isVerified, () {
      super.isVerified = value;
    });
  }

  late final _$verifyPinAsyncAction = AsyncAction(
    '_PinStore.verifyPin',
    context: context,
  );

  @override
  Future<void> verifyPin() {
    return _$verifyPinAsyncAction.run(() => super.verifyPin());
  }

  late final _$_PinStoreActionController = ActionController(
    name: '_PinStore',
    context: context,
  );

  @override
  void addDigit(String digit) {
    final _$actionInfo = _$_PinStoreActionController.startAction(
      name: '_PinStore.addDigit',
    );
    try {
      return super.addDigit(digit);
    } finally {
      _$_PinStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeDigit() {
    final _$actionInfo = _$_PinStoreActionController.startAction(
      name: '_PinStore.removeDigit',
    );
    try {
      return super.removeDigit();
    } finally {
      _$_PinStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_PinStoreActionController.startAction(
      name: '_PinStore.reset',
    );
    try {
      return super.reset();
    } finally {
      _$_PinStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pinDigits: ${pinDigits},
attempts: ${attempts},
isVerifying: ${isVerifying},
verificationError: ${verificationError},
isVerified: ${isVerified},
isLocked: ${isLocked},
remainingAttempts: ${remainingAttempts},
pinLength: ${pinLength},
canAttempt: ${canAttempt}
    ''';
  }
}
