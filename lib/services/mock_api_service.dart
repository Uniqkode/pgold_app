import 'package:pgold_app/models/dashboard_response.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/models/user.dart';
import 'package:pgold_app/services/api_result.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/services/report_persistence_service.dart';

class MockApiService implements ApiService {
  static const _testPin = '1234';

  final User _user;
  final List<Transaction> _transactions;
  final Set<String> _reportedTransactionIds = {};
  final ReportPersistenceService _persistence;
  bool _dashboardFails = false;
  bool _initialized = false;

  MockApiService({ReportPersistenceService? persistence})
      : _persistence = persistence ?? ReportPersistenceService(),
        _user = _parseUser(_mockUserJson),
        _transactions = _mockTransactionsJson
            .map((json) => Transaction.fromJson(json))
            .toList();

  Future<void> init() async {
    if (_initialized) return;
    final ids = await _persistence.loadReportedIds();
    _reportedTransactionIds.addAll(ids);
    _initialized = true;
  }

  void setDashboardFailure(bool shouldFail) {
    _dashboardFails = shouldFail;
  }

  @override
  Future<ApiResult<DashboardResponse>> fetchDashboard() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_dashboardFails) {
      _dashboardFails = false;
      return const Failure(
        'Unable to load dashboard. Please check your connection and try again.',
      );
    }

    final transactions = _transactions
        .map((t) => t.copyWith(
              hasActiveReport: _reportedTransactionIds.contains(t.id),
            ))
        .toList();

    return Success(DashboardResponse(user: _user, transactions: transactions));
  }

  @override
  Future<ApiResult<Transaction>> fetchTransactionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Failure('Transaction not found.');
    }

    final transaction = _transactions[index].copyWith(
      hasActiveReport: _reportedTransactionIds.contains(id),
    );

    return Success(transaction);
  }

  @override
  Future<ApiResult<Report>> submitTransactionReport({
    required String transactionId,
    required ReportReason reason,
    required String description,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_reportedTransactionIds.contains(transactionId)) {
      return const Failure(
        'This transaction already has an active report.',
      );
    }

    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      return const Failure('Transaction not found.');
    }

    final transaction = _transactions[index];
    if (transaction.status == TransactionStatus.failed) {
      return const Failure(
        'This transaction cannot be reported because it failed.',
      );
    }
    if (transaction.status == TransactionStatus.reversed) {
      return const Failure(
        'This transaction cannot be reported because it was reversed.',
      );
    }

    _reportedTransactionIds.add(transactionId);
    await _persistence.saveReportedId(transactionId);

    final report = Report(
      id: 'rpt_${DateTime.now().millisecondsSinceEpoch}',
      transactionId: transactionId,
      reason: reason,
      description: description,
      date: DateTime.now().toUtc().toIso8601String(),
    );

    return Success(report);
  }

  @override
  Future<ApiResult<void>> verifyTransactionPin(String pin) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (pin != _testPin) {
      return const Failure('Incorrect PIN. Please try again.');
    }

    return const Success(null);
  }

  static User _parseUser(Map<String, dynamic> json) {
    return User.fromJson(json);
  }

  static const _mockUserJson = {
    'id': 'usr_001',
    'name': 'Chidi',
    'wallet_balance': 250000.75,
    'kyc_level': 'Tier 2',
  };

  static const _mockTransactionsJson = [
    {
      'id': 'txn_001',
      'reference': 'PG-20260707-001',
      'title': 'Wallet Funding',
      'amount': 50000,
      'fee': 0,
      'type': 'wallet_funding',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Wallet funded via bank transfer',
      'date': '2026-07-07T10:30:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_002',
      'reference': 'PG-20260707-002',
      'title': 'Withdrawal',
      'amount': 20000,
      'fee': 100,
      'type': 'withdrawal',
      'status': 'pending',
      'direction': 'debit',
      'description': 'Withdrawal to saved bank account',
      'date': '2026-07-07T12:10:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_003',
      'reference': 'PG-20260707-003',
      'title': 'Gift Card Trade',
      'amount': 85000,
      'fee': 0,
      'type': 'gift_card_trade',
      'status': 'failed',
      'direction': 'credit',
      'description': 'Gift card trade payout',
      'date': '2026-07-06T09:15:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_004',
      'reference': 'PG-20260707-004',
      'title': 'Crypto Trade',
      'amount': 120000,
      'fee': 500,
      'type': 'crypto_trade',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Crypto sale payout',
      'date': '2026-07-05T16:45:00Z',
      'has_active_report': true,
    },
  ];
}
