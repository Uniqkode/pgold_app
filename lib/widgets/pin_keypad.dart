import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final void Function(String digit) onDigitPressed;
  final void Function() onBackspace;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        _buildRow(['4', '5', '6']),
        _buildRow(['7', '8', '9']),
        _buildLastRow(),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) => _KeypadButton(digit: d, onPressed: () => onDigitPressed(d))).toList(),
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 76),
        _KeypadButton(digit: '0', onPressed: () => onDigitPressed('0')),
        _KeypadButton(
          digit: '⌫',
          onPressed: onBackspace,
          isBackspace: true,
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String digit;
  final VoidCallback onPressed;
  final bool isBackspace;

  const _KeypadButton({
    required this.digit,
    required this.onPressed,
    this.isBackspace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Material(
          color: Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Center(
              child: isBackspace
                  ? Icon(Icons.backspace_outlined,
                      color: theme.colorScheme.onSurface, size: 24)
                  : Text(
                      digit,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
