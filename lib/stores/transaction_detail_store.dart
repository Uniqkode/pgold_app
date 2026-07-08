import 'package:mobx/mobx.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/services/api_service.dart';

part 'transaction_detail_store.g.dart';

class TransactionDetailStore = _TransactionDetailStore
    with _$TransactionDetailStore;

abstract class _TransactionDetailStore with Store {
  final ApiService _apiService;

  _TransactionDetailStore(this._apiService);

  @observable
  Transaction? transaction;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @computed
  bool get canReport => transaction?.canBeReported ?? false;

  @computed
  String? get reportBlockedReason => transaction?.reportBlockedReason;

  @action
  Future<void> loadTransaction(String id) async {
    isLoading = true;
    error = null;
    transaction = null;

    final result = await _apiService.fetchTransactionById(id);

    result.when(
      success: (data) {
        transaction = data;
        isLoading = false;
      },
      failure: (message) {
        error = message;
        isLoading = false;
      },
    );
  }

  @action
  void markAsReported() {
    if (transaction != null) {
      transaction = transaction!.copyWith(hasActiveReport: true);
    }
  }
}
