import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/widgets/pin_entry_view.dart';

class PinDialog extends StatelessWidget {
  final ApiService apiService;
  final String title;
  final String? amountLabel;
  final String? amount;
  final String? subtitle;
  final VoidCallback? onForgotPin;

  const PinDialog({
    super.key,
    required this.apiService,
    this.title = 'Enter PIN',
    this.amountLabel,
    this.amount,
    this.subtitle,
    this.onForgotPin,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ApiService apiService,
    String title = 'Enter PIN',
    String? amountLabel,
    String? amount,
    String? subtitle,
    VoidCallback? onForgotPin,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => PinDialog(
        apiService: apiService,
        title: title,
        amountLabel: amountLabel,
        amount: amount,
        subtitle: subtitle,
        onForgotPin: onForgotPin,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.93, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxWidth = math.min(mq.size.width * 0.95, 520);

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth.toDouble()),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Material(
              color: Colors.transparent,
              child: SizedBox.expand(
                child: PinEntryView(
                  apiService: apiService,
                  onVerified: () => Navigator.of(context).pop(true),
                  title: title,
                  amountLabel: amountLabel,
                  amount: amount,
                  subtitle:
                      subtitle ??
                      'Enter your 4-digit transaction PIN to confirm.',
                  onForgotPin: onForgotPin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
