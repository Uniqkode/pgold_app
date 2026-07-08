// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DashboardStore on _DashboardStore, Store {
  Computed<bool>? _$isEmptyComputed;

  @override
  bool get isEmpty => (_$isEmptyComputed ??= Computed<bool>(
    () => super.isEmpty,
    name: '_DashboardStore.isEmpty',
  )).value;

  late final _$userAtom = Atom(name: '_DashboardStore.user', context: context);

  @override
  User? get user {
    _$userAtom.reportRead();
    return super.user;
  }

  @override
  set user(User? value) {
    _$userAtom.reportWrite(value, super.user, () {
      super.user = value;
    });
  }

  late final _$transactionsAtom = Atom(
    name: '_DashboardStore.transactions',
    context: context,
  );

  @override
  ObservableList<Transaction> get transactions {
    _$transactionsAtom.reportRead();
    return super.transactions;
  }

  @override
  set transactions(ObservableList<Transaction> value) {
    _$transactionsAtom.reportWrite(value, super.transactions, () {
      super.transactions = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_DashboardStore.isLoading',
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
    name: '_DashboardStore.error',
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

  late final _$fetchDashboardAsyncAction = AsyncAction(
    '_DashboardStore.fetchDashboard',
    context: context,
  );

  @override
  Future<void> fetchDashboard() {
    return _$fetchDashboardAsyncAction.run(() => super.fetchDashboard());
  }

  late final _$_DashboardStoreActionController = ActionController(
    name: '_DashboardStore',
    context: context,
  );

  @override
  void updateTransactionReportStatus(String transactionId, bool hasReport) {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
      name: '_DashboardStore.updateTransactionReportStatus',
    );
    try {
      return super.updateTransactionReportStatus(transactionId, hasReport);
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
user: ${user},
transactions: ${transactions},
isLoading: ${isLoading},
error: ${error},
isEmpty: ${isEmpty}
    ''';
  }
}
