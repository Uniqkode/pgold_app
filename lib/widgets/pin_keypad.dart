import 'dart:math' as math;

import 'package:flutter/material.dart';

class SecurePinKeypad extends StatelessWidget {
  const SecurePinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onClosePressed,
    this.enabled = true,
    this.verticalSpacing = 8,
    this.horizontalSpacing = 6,
    this.buttonSize = 400,
    this.digitTextStyle,
    this.backspaceIconColor,
    this.doneLabel = 'Done',
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onClosePressed;
  final bool enabled;
  final double verticalSpacing;
  final double horizontalSpacing;
  final double buttonSize;
  final TextStyle? digitTextStyle;
  final Color? backspaceIconColor;
  final String doneLabel;

  static const List<List<String>> _keys = <List<String>>[
    <String>['1', '2', '3'],
    <String>['4', '5', '6'],
    <String>['7', '8', '9'],
    <String>['close', '0', 'backspace'],
  ];

  static const double _topRadius = 20;
  static const double _sheetHPadding = 14;
  static const double _sheetVPadding = 12;
  static const double _headerBarHeight = 44;
  static const double _keyHeightRatio = 0.50;
  static const double _minKeyWidth = 44;
  static const double _minKeyHeight = 34;
  static const double _minSpacing = 3;

  static double _rowWidth(double keyW, double h) => 3 * keyW + 3 * h;

  static double _totalHeight(double keyH, double v) {
    return 2 * _sheetVPadding + _headerBarHeight + v + 4 * (keyH + v);
  }

  static _KeypadColors _colorsFor(ThemeData theme) {
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final Color sheet = dark ? Colors.black : Colors.white;
    final Color keyFace = dark
        ? const Color(0xFF1C1C1C)
        : const Color(0xFFF0F0F0);

    return _KeypadColors(
      sheet: sheet,
      keyFace: keyFace,
      onKey: dark ? Colors.white : Colors.black87,
      headerMuted: dark ? Colors.white70 : Colors.black54,
      accent: cs.primary,
      outline: dark ? Colors.white24 : Colors.black26,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(theme);
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenW;
        final hasBoundedH = constraints.maxHeight.isFinite;
        final layoutMaxH = hasBoundedH
            ? constraints.maxHeight
            : math.max(
                140.0,
                screenH * 0.36 -
                    mq.padding.bottom -
                    mq.viewInsets.bottom * 0.35,
              );

        final innerMaxW = math.max(0.0, maxW - 2 * _sheetHPadding);
        var hSpace = horizontalSpacing;
        var vSpace = verticalSpacing;

        double keyHFor(double w) =>
            (w * _keyHeightRatio).clamp(_minKeyHeight, 56.0);

        final capW = math.max(0.0, (innerMaxW - 3 * hSpace) / 3);
        var keyW = math.max(_minKeyWidth, math.min(capW, buttonSize));
        var keyH = keyHFor(keyW);

        double headerBlockFor(double vs) =>
            2 * _sheetVPadding + _headerBarHeight + vs;

        double capKeyHeight(double vs) {
          final block = math.max(0.0, layoutMaxH - headerBlockFor(vs) - 4 * vs);
          return block / 4;
        }

        var capKeyH = capKeyHeight(vSpace);
        if (capKeyH > 0) {
          keyH = math.min(keyH, capKeyH).clamp(_minKeyHeight, 56.0);
        }

        for (var i = 0; i < 16; i++) {
          capKeyH = capKeyHeight(vSpace);
          keyH = math
              .min(keyHFor(keyW), capKeyH > 0 ? capKeyH : 56.0)
              .clamp(_minKeyHeight, 56.0);
          if (capKeyH <= 0 || keyH <= capKeyH + 0.5) break;
          if (vSpace > _minSpacing) {
            vSpace -= 1;
            continue;
          }
          if (hSpace > _minSpacing) hSpace -= 1;
        }

        hSpace = hSpace.clamp(_minSpacing, horizontalSpacing);
        vSpace = vSpace.clamp(_minSpacing, verticalSpacing);
        capKeyH = capKeyHeight(vSpace);
        if (capKeyH > 0) {
          keyH = math.min(keyHFor(keyW), capKeyH).clamp(_minKeyHeight, 56.0);
        }

        final totalInnerW = _rowWidth(keyW, hSpace);
        final totalH = _totalHeight(keyH, vSpace);

        final iconSize = (math.min(keyW, keyH) * 0.38).clamp(18.0, 26.0);
        final digitFont = (math.min(keyW, keyH) * 0.42).clamp(20.0, 28.0);

        final baseDigit =
            digitTextStyle ??
            theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            );
        final textStyle = (baseDigit ?? TextStyle(fontSize: digitFont))
            .copyWith(
              color: colors.onKey,
              fontSize: digitFont,
              fontWeight: baseDigit?.fontWeight ?? FontWeight.w500,
            );

        final iconColor = backspaceIconColor ?? colors.onKey;
        final keyRadius = (math.min(keyW, keyH) * 0.12).clamp(6.0, 12.0);

        final sheetChild = Padding(
          padding: const EdgeInsets.fromLTRB(
            _sheetHPadding,
            _sheetVPadding,
            _sheetHPadding,
            _sheetVPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _headerBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 18, color: colors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'PGold Secure Numeric Keypad',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.headerMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: vSpace),
              ..._keys.map((row) {
                return Padding(
                  padding: EdgeInsets.only(bottom: vSpace),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((value) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: hSpace / 2),
                        child: _buildKey(
                          value: value,
                          colors: colors,
                          keyW: keyW,
                          keyH: keyH,
                          borderRadius: keyRadius,
                          textStyle: textStyle,
                          iconColor: iconColor,
                          iconSize: iconSize,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        );

        final clipped = ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_topRadius),
          ),
          child: ColoredBox(
            color: colors.sheet,
            child: maxW.isFinite
                ? SizedBox(width: maxW, child: sheetChild)
                : sheetChild,
          ),
        );

        final outerW = totalInnerW + 2 * _sheetHPadding;
        final widthOverflow = maxW.isFinite && outerW > maxW + 0.5;
        final heightOverflow = totalH > layoutMaxH + 0.5;

        Widget result = clipped;
        if (maxW.isFinite) {
          result = SizedBox(width: maxW, child: result);
        }
        if (widthOverflow || heightOverflow) {
          result = FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomCenter,
            child: SizedBox(width: outerW, height: totalH, child: clipped),
          );
          if (maxW.isFinite) {
            result = SizedBox(width: maxW, child: result);
          }
          if (hasBoundedH && heightOverflow) {
            result = SizedBox(
              height: layoutMaxH,
              child: Align(alignment: Alignment.bottomCenter, child: result),
            );
          }
        }

        return result;
      },
    );
  }

  Widget _buildKey({
    required String value,
    required _KeypadColors colors,
    required double keyW,
    required double keyH,
    required double borderRadius,
    required TextStyle textStyle,
    required Color iconColor,
    required double iconSize,
  }) {
    final isBackspace = value == 'backspace';
    final isClose = value == 'close';
    final isGhost = isClose && onClosePressed == null;

    if (isGhost) {
      return SizedBox(width: keyW, height: keyH);
    }

    return Material(
      color: colors.keyFace,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: !enabled
            ? null
            : () {
                if (isBackspace) {
                  onBackspacePressed();
                } else if (isClose) {
                  onClosePressed?.call();
                } else {
                  onDigitPressed(value);
                }
              },
        splashColor: colors.accent.withValues(alpha: 0.12),
        highlightColor: colors.accent.withValues(alpha: 0.06),
        child: SizedBox(
          width: keyW,
          height: keyH,
          child: Center(
            child: isBackspace
                ? Icon(
                    Icons.backspace_outlined,
                    color: iconColor,
                    size: iconSize,
                  )
                : isClose
                ? Icon(
                    Icons.keyboard_hide_outlined,
                    color: iconColor,
                    size: iconSize,
                  )
                : Text(value, style: textStyle),
          ),
        ),
      ),
    );
  }
}

class _KeypadColors {
  const _KeypadColors({
    required this.sheet,
    required this.keyFace,
    required this.onKey,
    required this.headerMuted,
    required this.accent,
    required this.outline,
  });

  final Color sheet;
  final Color keyFace;
  final Color onKey;
  final Color headerMuted;
  final Color accent;
  final Color outline;
}
