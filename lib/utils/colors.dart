import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const brand = Color(0xFF1A237E);

  // Transaction status
  static const statusSuccess = Color(0xFF16A34A);
  static const statusPending = Color(0xFFD97706);
  static const statusFailed = Color(0xFFDC2626);
  static const statusReversed = Color(0xFF6B7280);

  // Amount direction
  static const amountCredit = Color(0xFF16A34A);
  static const amountDebit = Color(0xFFDC2626);

  // Report
  static const reportActive = Color(0xFFF57C00);
  static const reportInactive = Color(0xFF9E9E9E);
  static const reportBlockedIcon = Color(0xFFFF8F00);
  static const reportBlockedText = Color(0xFFE65100);

  // Feedback
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);
  static const errorBg = Color(0xFFFFCDD2);

  // Grey scale
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey900 = Color(0xFF212121);

  // Feedback icons
  static const errorIcon = Color(0xFFEF5350);

  // White / transparent
  static const white = Colors.white;

  // Keypad (fixed theme colors)
  static const keypadLightFace = Color(0xFFF0F0F0);
  static const keypadDarkFace = Color(0xFF1C1C1C);
}
