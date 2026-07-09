import 'package:flutter/material.dart';
import 'package:pgold_app/models/transaction.dart';
import 'package:pgold_app/utils/colors.dart';

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TransactionStatus.successful => (AppColors.statusSuccess, 'Successful'),
      TransactionStatus.pending => (AppColors.statusPending, 'Pending'),
      TransactionStatus.failed => (AppColors.statusFailed, 'Failed'),
      TransactionStatus.reversed => (AppColors.statusReversed, 'Reversed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
