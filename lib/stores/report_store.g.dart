// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ReportStore on _ReportStore, Store {
  Computed<int>? _$descriptionCharCountComputed;

  @override
  int get descriptionCharCount =>
      (_$descriptionCharCountComputed ??= Computed<int>(
        () => super.descriptionCharCount,
        name: '_ReportStore.descriptionCharCount',
      )).value;
  Computed<String?>? _$descriptionErrorComputed;

  @override
  String? get descriptionError =>
      (_$descriptionErrorComputed ??= Computed<String?>(
        () => super.descriptionError,
        name: '_ReportStore.descriptionError',
      )).value;
  Computed<bool>? _$isFormValidComputed;

  @override
  bool get isFormValid => (_$isFormValidComputed ??= Computed<bool>(
    () => super.isFormValid,
    name: '_ReportStore.isFormValid',
  )).value;

  late final _$selectedReasonAtom = Atom(
    name: '_ReportStore.selectedReason',
    context: context,
  );

  @override
  ReportReason? get selectedReason {
    _$selectedReasonAtom.reportRead();
    return super.selectedReason;
  }

  @override
  set selectedReason(ReportReason? value) {
    _$selectedReasonAtom.reportWrite(value, super.selectedReason, () {
      super.selectedReason = value;
    });
  }

  late final _$descriptionAtom = Atom(
    name: '_ReportStore.description',
    context: context,
  );

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  late final _$isSubmittingAtom = Atom(
    name: '_ReportStore.isSubmitting',
    context: context,
  );

  @override
  bool get isSubmitting {
    _$isSubmittingAtom.reportRead();
    return super.isSubmitting;
  }

  @override
  set isSubmitting(bool value) {
    _$isSubmittingAtom.reportWrite(value, super.isSubmitting, () {
      super.isSubmitting = value;
    });
  }

  late final _$submissionErrorAtom = Atom(
    name: '_ReportStore.submissionError',
    context: context,
  );

  @override
  String? get submissionError {
    _$submissionErrorAtom.reportRead();
    return super.submissionError;
  }

  @override
  set submissionError(String? value) {
    _$submissionErrorAtom.reportWrite(value, super.submissionError, () {
      super.submissionError = value;
    });
  }

  late final _$submittedReportAtom = Atom(
    name: '_ReportStore.submittedReport',
    context: context,
  );

  @override
  Report? get submittedReport {
    _$submittedReportAtom.reportRead();
    return super.submittedReport;
  }

  @override
  set submittedReport(Report? value) {
    _$submittedReportAtom.reportWrite(value, super.submittedReport, () {
      super.submittedReport = value;
    });
  }

  late final _$submitReportAsyncAction = AsyncAction(
    '_ReportStore.submitReport',
    context: context,
  );

  @override
  Future<void> submitReport(String transactionId) {
    return _$submitReportAsyncAction.run(
      () => super.submitReport(transactionId),
    );
  }

  late final _$_ReportStoreActionController = ActionController(
    name: '_ReportStore',
    context: context,
  );

  @override
  void setReason(ReportReason reason) {
    final _$actionInfo = _$_ReportStoreActionController.startAction(
      name: '_ReportStore.setReason',
    );
    try {
      return super.setReason(reason);
    } finally {
      _$_ReportStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDescription(String value) {
    final _$actionInfo = _$_ReportStoreActionController.startAction(
      name: '_ReportStore.setDescription',
    );
    try {
      return super.setDescription(value);
    } finally {
      _$_ReportStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_ReportStoreActionController.startAction(
      name: '_ReportStore.reset',
    );
    try {
      return super.reset();
    } finally {
      _$_ReportStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedReason: ${selectedReason},
description: ${description},
isSubmitting: ${isSubmitting},
submissionError: ${submissionError},
submittedReport: ${submittedReport},
descriptionCharCount: ${descriptionCharCount},
descriptionError: ${descriptionError},
isFormValid: ${isFormValid}
    ''';
  }
}
