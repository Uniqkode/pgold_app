import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/models/user.dart';

class DashboardResponse {
  final User user;
  final List<Transaction> transactions;

  const DashboardResponse({
    required this.user,
    required this.transactions,
  });
}
