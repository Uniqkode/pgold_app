import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/pin_store.dart';
import 'package:pgold_app/stores/report_store.dart';
import 'package:pgold_app/widgets/pin_dialog.dart';

class ReportScreen extends StatefulWidget {
  final String transactionId;
  final ApiService apiService;

  const ReportScreen({
    super.key,
    required this.transactionId,
    required this.apiService,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final ReportStore _reportStore;

  @override
  void initState() {
    super.initState();
    _reportStore = ReportStore(widget.apiService);
  }

  Future<void> _handleSubmit() async {
    if (PinStoreManager.shared(widget.apiService).isLocked) {
      await _showRestrictedDialog();
      return;
    }

    final confirmed = await _showPinDialog();
    if (!mounted) return;

    if (PinStoreManager.shared(widget.apiService).isLocked) {
      await _showRestrictedDialog();
      return;
    }

    if (confirmed != true) return;

    await _reportStore.submitReport(widget.transactionId);
    if (!mounted) return;

    if (_reportStore.submittedReport != null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle,
              color: Colors.green, size: 48),
          title: const Text('Report Submitted'),
          content: const Text(
            'Your report has been received. We will review it '
            'and take appropriate action.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _showRestrictedDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(Icons.lock_rounded, size: 48, color: Colors.red[400]),
        title: const Text('Access Restricted'),
        content: const Text(
          'You have been restricted from using the PIN feature '
          'due to multiple incorrect attempts. Please try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPinDialog() {
    return PinDialog.show(
      context,
      apiService: widget.apiService,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Transaction')),
      body: Observer(
        builder: (_) {
          final store = _reportStore;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Why are you reporting this transaction?',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReportReason>(
                value: store.selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Report Reason',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a reason'),
                items: ReportReason.values.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) store.setReason(value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 5,
                maxLength: 250,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: const OutlineInputBorder(),
                  helperText: '${store.descriptionCharCount}/250 characters',
                  helperStyle:
                      TextStyle(color: Colors.grey[500], fontSize: 12),
                  errorText: store.descriptionError,
                ),
                onChanged: store.setDescription,
              ),
              if (store.submissionError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.submissionError!,
                          style:
                              TextStyle(color: Colors.red[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (!store.isFormValid || store.isSubmitting)
                      ? null
                      : _handleSubmit,
                  child: store.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Report'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _reportStore.reset();
    super.dispose();
  }
}
