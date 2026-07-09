import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/utils/colors.dart';
import 'package:pgold_app/stores/transaction_detail_store.dart';
import 'package:pgold_app/utils/formatters.dart';
import 'package:pgold_app/widgets/status_badge.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  final ApiService apiService;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    required this.apiService,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late final TransactionDetailStore _store;

  @override
  void initState() {
    super.initState();
    _store = TransactionDetailStore(widget.apiService);
    _store.loadTransaction(widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _store.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () =>
                          _store.loadTransaction(widget.transactionId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final txn = _store.transaction;
          if (txn == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailCard(
                children: [
                  _buildRow('Title', txn.title),
                  _buildRow('Reference', txn.reference),
                  _buildRow('Amount', formatCurrency(txn.amount)),
                  if (txn.fee > 0) _buildRow('Fee', formatCurrency(txn.fee)),
                  _buildRow(
                    'Status',
                    null,
                    trailing: StatusBadge(status: txn.status),
                  ),
                  _buildRow('Type', txn.type.displayName),
                  _buildRow('Date', formatDate(txn.date)),
                ],
              ),
              const SizedBox(height: 16),
              _DetailCard(
                title: 'Description',
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      txn.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (txn.hasActiveReport)
                _DetailCard(
                  title: 'Report Status',
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: AppColors.reportActive,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This transaction has been reported to our '
                            'support team. We are reviewing it and will '
                            'get back to you.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.reportActive,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              if (_store.reportBlockedReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.reportBlockedIcon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.reportBlockedIcon.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.reportBlockedIcon,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _store.reportBlockedReason!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.reportBlockedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_store.canReport) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final reported = await context.push<bool>(
                        '/report-transaction/${txn.id}',
                      );
                      if (reported == true) {
                        _store.markAsReported();
                      }
                    },
                    child: const Text('Report Transaction'),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String? value, {Widget? trailing}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          trailing ??
              Expanded(
                child: Text(
                  value ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _DetailCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Divider(),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
