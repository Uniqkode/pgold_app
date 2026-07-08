import 'package:flutter/material.dart';
import 'package:pgold_app/models/transaction.dart';

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TransactionStatus.successful => (const Color(0xFF16A34A), 'Successful'),
      TransactionStatus.pending => (const Color(0xFFD97706), 'Pending'),
      TransactionStatus.failed => (const Color(0xFFDC2626), 'Failed'),
      TransactionStatus.reversed => (const Color(0xFF6B7280), 'Reversed'),
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
