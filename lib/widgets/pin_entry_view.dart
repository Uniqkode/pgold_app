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

class _PinEntryViewState extends State<PinEntryView>
    with SingleTickerProviderStateMixin {
  late final PinStore _pinStore;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _pinStore = PinStore(widget.apiService);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = TweenSequence<double>([
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
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              widget.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: _buildPinDots(theme),
        ),
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
        const SizedBox(height: 20),
        if (_pinStore.isVerifying)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          )
        else
          PinKeypad(
            enabled: !_pinStore.isVerifying,
            verticalSpacing: 10,
            horizontalSpacing: 12,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: filled
                ? Icon(Icons.circle,
                    size: 14, color: theme.colorScheme.primary)
                : Icon(Icons.circle_outlined,
                    size: 14, color: Colors.grey[300]),
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
    _shakeController.dispose();
    super.dispose();
  }
}
