import 'package:mobx/mobx.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/models/user.dart';
import 'package:pgold_app/services/api_service.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  final ApiService _apiService;

  _DashboardStore(this._apiService);

  @observable
  User? user;

  @observable
  ObservableList<Transaction> transactions = ObservableList<Transaction>();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @computed
  bool get isEmpty => !isLoading && error == null && transactions.isEmpty;

  @action
  Future<void> fetchDashboard() async {
    isLoading = true;
    error = null;

    final result = await _apiService.fetchDashboard();

    result.when(
      success: (data) {
        user = data.user;
        transactions = ObservableList.of(data.transactions);
        isLoading = false;
      },
      failure: (message) {
        error = message;
        isLoading = false;
      },
    );
  }

  @action
  void updateTransactionReportStatus(String transactionId, bool hasReport) {
    final index = transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      transactions[index] = transactions[index].copyWith(
        hasActiveReport: hasReport,
      );
    }
  }
}
