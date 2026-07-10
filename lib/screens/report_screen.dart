import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/pin_store.dart';
import 'package:pgold_app/stores/report_store.dart';
import 'package:pgold_app/utils/colors.dart';
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
      _showRestrictedDialog();
      return;
    }

    final confirmed = await _showPinDialog();
    if (!mounted) return;

    if (PinStoreManager.shared(widget.apiService).isLocked) {
      _showRestrictedDialog();
      return;
    }

    if (confirmed != true) return;

    await _reportStore.submitReport(widget.transactionId);
    if (!mounted) return;

    if (_reportStore.submittedReport != null) {
      _showSuccessDialog();
    } else if (_reportStore.submissionError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_reportStore.submissionError!)),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: const Text('Report Submitted'),
        content: const Text(
          'Your report has been received. We will review it and take appropriate action.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (mounted) context.pop(true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showRestrictedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.lock_rounded, size: 48, color: AppColors.error),
        title: const Text('Access Restricted'),
        content: const Text(
          'You have been restricted from using the PIN feature due to multiple incorrect attempts. Please try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
              _buildHeader(theme),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<ReportReason>(
                        value: store.selectedReason,
                        decoration: InputDecoration(
                          labelText: 'Report Reason',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
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
                      const SizedBox(height: 20),
                      TextField(
                        maxLines: 5,
                        maxLength: 250,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          helperText:
                              '${store.descriptionCharCount}/250 characters',
                          helperStyle: TextStyle(
                              color: AppColors.grey500, fontSize: 12),
                          errorText: store.descriptionError,
                        ),
                        onChanged: store.setDescription,
                      ),
                    ],
                  ),
                ),
              ),
              if (store.submissionError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          store.submissionError!,
                          style: TextStyle(color: Colors.red[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: (!store.isFormValid || store.isSubmitting)
                      ? null
                      : _handleSubmit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: store.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Submit Report'),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.reportActive, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report a Transaction',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.reportActive,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please provide details about the issue. '
                  'Your report will be reviewed by our support team.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grey700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reportStore.reset();
    super.dispose();
  }
}
