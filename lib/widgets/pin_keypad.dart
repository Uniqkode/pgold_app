import 'dart:math' as math;

import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final void Function(String digit) onDigitPressed;
  final VoidCallback onBackspace;
  final bool enabled;
  final double verticalSpacing;
  final double horizontalSpacing;
  final double buttonSize;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.enabled = true,
    this.verticalSpacing = 8,
    this.horizontalSpacing = 6,
    this.buttonSize = 400,
  });

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final keyFace = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF0F0F0);
    final onKey = isDark ? Colors.white : Colors.black87;
    final accent = cs.primary;
    final outline =
        isDark ? Colors.white.withValues(alpha: 0.24) : Colors.black.withValues(alpha: 0.26);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final innerW = math.max(0.0, maxW);
        final capW = math.max(0.0, (innerW - 3 * horizontalSpacing) / 3);
        final keyW = math.min(capW, buttonSize).clamp(44.0, double.infinity);
        final keyH = (keyW * 0.55).clamp(34.0, 56.0);
        final borderRadius = (math.min(keyW, keyH) * 0.12).clamp(6.0, 12.0);
        final iconSize = (math.min(keyW, keyH) * 0.38).clamp(18.0, 26.0);
        final fontSize = (math.min(keyW, keyH) * 0.42).clamp(20.0, 28.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _keys.map((row) {
            return Padding(
              padding: EdgeInsets.only(bottom: verticalSpacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
                    child: _KeypadButton(
                      value: value,
                      keyW: keyW,
                      keyH: keyH,
                      borderRadius: borderRadius,
                      iconSize: iconSize,
                      fontSize: fontSize,
                      keyFace: keyFace,
                      onKey: onKey,
                      accent: accent,
                      outline: outline,
                      enabled: enabled,
                      onDigitPressed: onDigitPressed,
                      onBackspace: onBackspace,
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String value;
  final double keyW;
  final double keyH;
  final double borderRadius;
  final double iconSize;
  final double fontSize;
  final Color keyFace;
  final Color onKey;
  final Color accent;
  final Color outline;
  final bool enabled;
  final void Function(String digit) onDigitPressed;
  final VoidCallback onBackspace;

  const _KeypadButton({
    required this.value,
    required this.keyW,
    required this.keyH,
    required this.borderRadius,
    required this.iconSize,
    required this.fontSize,
    required this.keyFace,
    required this.onKey,
    required this.accent,
    required this.outline,
    required this.enabled,
    required this.onDigitPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final isBackspace = value == 'backspace';
    final isGhost = value.isEmpty;

    if (isGhost) {
      return SizedBox(width: keyW, height: keyH);
    }

    return Material(
      color: keyFace,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: !enabled
            ? null
            : () {
                if (isBackspace) {
                  onBackspace();
                } else {
                  onDigitPressed(value);
                }
              },
        splashColor: accent.withValues(alpha: 0.12),
        highlightColor: accent.withValues(alpha: 0.06),
        child: SizedBox(
          width: keyW,
          height: keyH,
          child: Center(
            child: isBackspace
                ? Icon(Icons.backspace_outlined, color: onKey, size: iconSize)
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: onKey,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
