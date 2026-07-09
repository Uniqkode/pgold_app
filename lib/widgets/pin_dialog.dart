import 'package:flutter/material.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/widgets/pin_entry_view.dart';

class PinDialog extends StatelessWidget {
  final ApiService apiService;

  const PinDialog({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Transaction PIN'),
      content: PinEntryView(
        apiService: apiService,
        onVerified: () => Navigator.of(context).pop(true),
        subtitle: 'Enter your 4-digit transaction PIN to confirm.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
