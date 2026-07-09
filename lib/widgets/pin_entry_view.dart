import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/pin_store.dart';
import 'package:pgold_app/widgets/pin_keypad.dart';

class PinEntryView extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onVerified;
  final String? subtitle;

  const PinEntryView({
    super.key,
    required this.apiService,
    required this.onVerified,
    this.subtitle,
  });

  @override
  State<PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends State<PinEntryView> {
  late final PinStore _pinStore;

  @override
  void initState() {
    super.initState();
    _pinStore = PinStore(widget.apiService);
  }

  void _onDigitPressed(String digit) {
    _pinStore.addDigit(digit);
    if (_pinStore.pinLength == 4) {
      _pinStore.verifyPin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Observer(
      builder: (_) {
        if (_pinStore.isLocked) {
          return _buildLocked(theme);
        }
        if (_pinStore.isVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onVerified();
          });
          return _buildVerifying(theme);
        }
        return _buildPinEntry(theme);
      },
    );
  }

  Widget _buildPinEntry(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              widget.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        _buildPinDots(theme),
        if (_pinStore.verificationError != null) ...[
          const SizedBox(height: 12),
          Text(
            _pinStore.verificationError!,
            style: TextStyle(color: Colors.red[700], fontSize: 13),
          ),
        ],
        if (!_pinStore.isLocked) ...[
          const SizedBox(height: 8),
          Text(
            '${_pinStore.remainingAttempts} attempt(s) remaining',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
        const SizedBox(height: 24),
        if (_pinStore.isVerifying)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          )
        else
          PinKeypad(
            onDigitPressed: _onDigitPressed,
            onBackspace: _pinStore.removeDigit,
          ),
      ],
    );
  }

  Widget _buildPinDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _pinStore.pinLength;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: filled ? theme.colorScheme.primary : Colors.grey[400]!,
              width: filled ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: filled
                ? Icon(Icons.circle,
                    size: 16, color: theme.colorScheme.primary)
                : Icon(Icons.circle_outlined,
                    size: 16, color: Colors.grey[300]),
          ),
        );
      }),
    );
  }

  Widget _buildLocked(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Too many incorrect attempts.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifying(ThemeData theme) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verifying PIN...'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinStore.reset();
    super.dispose();
  }
}
