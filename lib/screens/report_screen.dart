import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/report_store.dart';

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
    final pin = await _showPinDialog();
    if (pin == null || !mounted) return;

    final pinResult = await widget.apiService.verifyTransactionPin(pin);
    if (!mounted) return;

    pinResult.when(
      success: (_) async {
        await _reportStore.submitReport(widget.transactionId);
        if (!mounted) return;

        if (_reportStore.submittedReport != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')),
          );
          Navigator.of(context).pop(true);
        }
      },
      failure: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
    );
  }

  Future<String?> _showPinDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SimplePinDialog(),
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

class _SimplePinDialog extends StatefulWidget {
  @override
  State<_SimplePinDialog> createState() => _SimplePinDialogState();
}

class _SimplePinDialogState extends State<_SimplePinDialog> {
  final _pinController = TextEditingController();
  bool _showError = false;
  int _attempts = 0;

  void _confirm() {
    final pin = _pinController.text;
    if (pin != '1234') {
      setState(() {
        _attempts++;
        _showError = true;
      });
      _pinController.clear();
      return;
    }
    Navigator.of(context).pop(pin);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = _attempts >= 3;

    return AlertDialog(
      title: const Text('Enter Transaction PIN'),
      content: isLocked
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                const Text(
                  'Too many incorrect attempts. '
                  'Please try again later.',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter your 4-digit transaction PIN to confirm.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    border: const OutlineInputBorder(),
                    errorText:
                        _showError ? 'Incorrect PIN. Please try again.' : null,
                  ),
                  onChanged: (_) => setState(() => _showError = false),
                ),
                const SizedBox(height: 8),
                Text(
                  '${3 - _attempts} attempt(s) remaining',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        _pinController.text.length == 4 ? _confirm : null,
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: isLocked
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
