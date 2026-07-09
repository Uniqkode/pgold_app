import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:pgold_app/services/api_service.dart';
import 'package:pgold_app/stores/pin_store.dart';
import 'package:pgold_app/widgets/pin_keypad.dart';

class PinEntryView extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onVerified;
  final String title;
  final String? amountLabel;
  final String? amount;
  final String? subtitle;
  final VoidCallback? onForgotPin;

  const PinEntryView({
    super.key,
    required this.apiService,
    required this.onVerified,
    this.title = 'Enter PIN',
    this.amountLabel,
    this.amount,
    this.subtitle,
    this.onForgotPin,
  });

  @override
  State<PinEntryView> createState() => _PinEntryViewState();
}

class _PinEntryViewState extends State<PinEntryView>
    with SingleTickerProviderStateMixin {
  late final PinStore _pinStore;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String? _lastError;
  bool _useFingerprint = false;
  bool _showKeypad = true;

  @override
  void initState() {
    super.initState();
    _pinStore = PinStoreManager.shared(widget.apiService);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 12, end: -10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
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
        if (_pinStore.verificationError != null &&
            _pinStore.verificationError != _lastError) {
          _lastError = _pinStore.verificationError;
          _shakeController.forward(from: 0);
        }

        if (_pinStore.isLocked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop();
          });
          return _buildLocked(theme);
        }
        if (_pinStore.isVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onVerified();
          });
          return _buildVerifying(theme);
        }

        return SizedBox.expand(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 24,
                    ),
                    child: _buildPinCard(theme),
                  ),
                ),
              ),
              if (_showKeypad)
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: SecurePinKeypad(
                      enabled: !_pinStore.isVerifying,
                      verticalSpacing: 10,
                      horizontalSpacing: 12,
                      onDigitPressed: _onDigitPressed,
                      onBackspacePressed: _pinStore.removeDigit,
                      onClosePressed: () => setState(() => _showKeypad = false),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.amount != null || widget.amountLabel != null) ...[
              const SizedBox(height: 16),
              if (widget.amountLabel != null)
                Text(
                  widget.amountLabel!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              if (widget.amount != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.amount!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => setState(() => _showKeypad = true),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: _buildPinDots(theme),
              ),
            ),
            if (_pinStore.verificationError != null) ...[
              const SizedBox(height: 14),
              Text(
                _pinStore.verificationError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _pinStore.isVerifying
                        ? 'Verifying PIN...'
                        : '${_pinStore.remainingAttempts} attempt(s) remaining',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (widget.onForgotPin != null)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: widget.onForgotPin,
                    child: Text(
                      'Forgot my PIN',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _buildFingerprintToggle(theme),
            if (_pinStore.isVerifying)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _pinStore.pinLength;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 54,
          height: 62,
          decoration: BoxDecoration(
            border: Border.all(
              color: filled ? theme.colorScheme.primary : Colors.grey[400]!,
              width: filled ? 2.2 : 1.4,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: filled
                ? Icon(Icons.circle, size: 16, color: theme.colorScheme.primary)
                : Icon(
                    Icons.circle_outlined,
                    size: 16,
                    color: Colors.grey[300],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildFingerprintToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fingerprint,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Use Fingerprint next time',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _useFingerprint,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (value) {
              setState(() {
                _useFingerprint = value;
              });
            },
          ),
        ],
      ),
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
    _pinStore.clearEntry();
    _shakeController.dispose();
    super.dispose();
  }
}
