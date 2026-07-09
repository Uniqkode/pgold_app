import 'package:flutter/material.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/utils/colors.dart';
import 'package:pgold_app/utils/formatters.dart';
import 'package:pgold_app/widgets/status_badge.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = transaction.direction == TransactionDirection.credit
        ? AppColors.amountCredit
        : AppColors.amountDebit;
    final prefix = transaction.direction == TransactionDirection.credit
        ? '+'
        : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(transaction.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(status: transaction.status),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix${formatCurrency(transaction.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.hasActiveReport)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.reportActive,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
