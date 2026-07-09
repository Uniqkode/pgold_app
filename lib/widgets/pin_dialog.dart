import 'package:flutter/material.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/widgets/pin_entry_view.dart';

class PinDialog extends StatelessWidget {
  final ApiService apiService;

  const PinDialog({super.key, required this.apiService});

  static Future<bool?> show(
    BuildContext context, {
    required ApiService apiService,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinDialog(apiService: apiService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinEntryView(
                apiService: apiService,
                onVerified: () => Navigator.of(context).pop(true),
                subtitle: 'Enter your 4-digit transaction PIN to confirm.',
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
