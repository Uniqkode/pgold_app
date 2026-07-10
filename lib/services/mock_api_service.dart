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
  bool _simulateEmptyTransactions = false;
  bool _simulateTransactionNotFound = false;
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

  void setEmptyTransactions(bool shouldEmpty) {
    _simulateEmptyTransactions = shouldEmpty;
  }

  void setTransactionNotFound(bool shouldFail) {
    _simulateTransactionNotFound = shouldFail;
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

    if (_simulateEmptyTransactions) {
      return Success(DashboardResponse(user: _user, transactions: []));
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

    if (_simulateTransactionNotFound) {
      return const Failure('Transaction not found.');
    }

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
      'reference': 'PG-20260709-001',
      'title': 'Wallet Funding',
      'amount': 50000,
      'fee': 0,
      'type': 'wallet_funding',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Wallet funded via bank transfer',
      'date': '2026-07-09T10:30:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_002',
      'reference': 'PG-20260709-002',
      'title': 'Withdrawal',
      'amount': 20000,
      'fee': 100,
      'type': 'withdrawal',
      'status': 'pending',
      'direction': 'debit',
      'description': 'Withdrawal to saved bank account',
      'date': '2026-07-09T12:10:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_008',
      'reference': 'PG-20260709-003',
      'title': 'Airtime Purchase',
      'amount': 5000,
      'fee': 0,
      'type': 'withdrawal',
      'status': 'successful',
      'direction': 'debit',
      'description': 'Airtime top-up for 07031234567',
      'date': '2026-07-09T08:15:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_003',
      'reference': 'PG-20260708-001',
      'title': 'Gift Card Trade',
      'amount': 85000,
      'fee': 0,
      'type': 'gift_card_trade',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Gift card trade payout',
      'date': '2026-07-08T09:15:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_009',
      'reference': 'PG-20260708-002',
      'title': 'Internet Data',
      'amount': 3000,
      'fee': 0,
      'type': 'withdrawal',
      'status': 'successful',
      'direction': 'debit',
      'description': 'Internet data bundle purchase',
      'date': '2026-07-08T14:20:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_004',
      'reference': 'PG-20260707-001',
      'title': 'Crypto Trade',
      'amount': 120000,
      'fee': 500,
      'type': 'crypto_trade',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Crypto sale payout',
      'date': '2026-07-07T16:45:00Z',
      'has_active_report': true,
    },
    {
      'id': 'txn_010',
      'reference': 'PG-20260707-002',
      'title': 'Wallet Funding',
      'amount': 25000,
      'fee': 0,
      'type': 'wallet_funding',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Wallet funded via card deposit',
      'date': '2026-07-07T11:00:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_005',
      'reference': 'PG-20260705-001',
      'title': 'Withdrawal',
      'amount': 15000,
      'fee': 75,
      'type': 'withdrawal',
      'status': 'failed',
      'direction': 'debit',
      'description': 'Withdrawal to GTBank',
      'date': '2026-07-05T10:00:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_011',
      'reference': 'PG-20260704-001',
      'title': 'Gift Card Trade',
      'amount': 45000,
      'fee': 0,
      'type': 'gift_card_trade',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Apple Gift Card trade payout',
      'date': '2026-07-04T15:30:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_006',
      'reference': 'PG-20260702-001',
      'title': 'Wallet Funding',
      'amount': 100000,
      'fee': 0,
      'type': 'wallet_funding',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Wallet funded via bank transfer',
      'date': '2026-07-02T09:00:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_012',
      'reference': 'PG-20260628-001',
      'title': 'Crypto Trade',
      'amount': 200000,
      'fee': 800,
      'type': 'crypto_trade',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Bitcoin sale payout',
      'date': '2026-06-28T13:00:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_007',
      'reference': 'PG-20260620-001',
      'title': 'Withdrawal',
      'amount': 50000,
      'fee': 250,
      'type': 'withdrawal',
      'status': 'reversed',
      'direction': 'debit',
      'description': 'Withdrawal to UBA — reversed',
      'date': '2026-06-20T11:20:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_013',
      'reference': 'PG-20260615-001',
      'title': 'Gift Card Trade',
      'amount': 32000,
      'fee': 0,
      'type': 'gift_card_trade',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Steam Gift Card trade payout',
      'date': '2026-06-15T10:45:00Z',
      'has_active_report': false,
    },
    {
      'id': 'txn_014',
      'reference': 'PG-20260510-001',
      'title': 'Wallet Funding',
      'amount': 75000,
      'fee': 0,
      'type': 'wallet_funding',
      'status': 'successful',
      'direction': 'credit',
      'description': 'Wallet funded via bank transfer',
      'date': '2026-05-10T08:30:00Z',
      'has_active_report': false,
    },
  ];
}
