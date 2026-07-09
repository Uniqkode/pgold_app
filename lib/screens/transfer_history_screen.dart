import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pgold_app/utils/colors.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/utils/formatters.dart';
import 'package:pgold_app/widgets/transaction_card.dart';

class TransferHistoryScreen extends StatefulWidget {
  final ApiService apiService;

  const TransferHistoryScreen({super.key, required this.apiService});

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  List<Transaction>? _transactions;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.apiService.fetchDashboard();

    result.when(
      success: (data) {
        if (mounted) {
          setState(() {
            _transactions = data.transactions;
            _isLoading = false;
          });
        }
      },
      failure: (message) {
        if (mounted) {
          setState(() {
            _error = message;
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer History')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final transactions = _transactions ?? [];
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found.'));
    }

    // Sort most recent first
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by date label
    final grouped = <String, List<Transaction>>{};
    for (final txn in sorted) {
      final label = dateGroupLabel(txn.date);
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(txn);
    }

    // Ordered group keys: Today, Yesterday, then months chronologically
    final orderedKeys = <String>[];
    if (grouped.containsKey('Today')) orderedKeys.add('Today');
    if (grouped.containsKey('Yesterday')) orderedKeys.add('Yesterday');
    for (final key in grouped.keys) {
      if (key != 'Today' && key != 'Yesterday') {
        orderedKeys.add(key);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        for (final label in orderedKeys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          for (final txn in grouped[label]!)
            TransactionCard(
              transaction: txn,
              onTap: () {
                context.push('/transaction-details/${txn.id}');
              },
            ),
        ],
      ],
    );
  }
}
