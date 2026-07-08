import 'package:pgold_app/models/dashboard_response.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/services/api_result.dart';

abstract class ApiService {
  Future<ApiResult<DashboardResponse>> fetchDashboard();

  Future<ApiResult<Transaction>> fetchTransactionById(String id);

  Future<ApiResult<Report>> submitTransactionReport({
    required String transactionId,
    required ReportReason reason,
    required String description,
  });

  Future<ApiResult<void>> verifyTransactionPin(String pin);
}
