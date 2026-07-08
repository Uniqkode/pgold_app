// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TransactionDetailStore on _TransactionDetailStore, Store {
  Computed<bool>? _$canReportComputed;

  @override
  bool get canReport => (_$canReportComputed ??= Computed<bool>(
    () => super.canReport,
    name: '_TransactionDetailStore.canReport',
  )).value;
  Computed<String?>? _$reportBlockedReasonComputed;

  @override
  String? get reportBlockedReason =>
      (_$reportBlockedReasonComputed ??= Computed<String?>(
        () => super.reportBlockedReason,
        name: '_TransactionDetailStore.reportBlockedReason',
      )).value;

  late final _$transactionAtom = Atom(
    name: '_TransactionDetailStore.transaction',
    context: context,
  );

  @override
  Transaction? get transaction {
    _$transactionAtom.reportRead();
    return super.transaction;
  }

  @override
  set transaction(Transaction? value) {
    _$transactionAtom.reportWrite(value, super.transaction, () {
      super.transaction = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_TransactionDetailStore.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorAtom = Atom(
    name: '_TransactionDetailStore.error',
    context: context,
  );

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$loadTransactionAsyncAction = AsyncAction(
    '_TransactionDetailStore.loadTransaction',
    context: context,
  );

  @override
  Future<void> loadTransaction(String id) {
    return _$loadTransactionAsyncAction.run(() => super.loadTransaction(id));
  }

  late final _$_TransactionDetailStoreActionController = ActionController(
    name: '_TransactionDetailStore',
    context: context,
  );

  @override
  void markAsReported() {
    final _$actionInfo = _$_TransactionDetailStoreActionController.startAction(
      name: '_TransactionDetailStore.markAsReported',
    );
    try {
      return super.markAsReported();
    } finally {
      _$_TransactionDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
transaction: ${transaction},
isLoading: ${isLoading},
error: ${error},
canReport: ${canReport},
reportBlockedReason: ${reportBlockedReason}
    ''';
  }
}
