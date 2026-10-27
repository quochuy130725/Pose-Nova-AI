import 'package:intl/intl.dart';

/// Formatting utilities for currency and IDs in PoseNova AI
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat('#,###', 'vi_VN');

  /// Formats numbers to VND string e.g. "2.500.000 ₫"
  static String formatVnd(num amount) {
    return '${_vndFormat.format(amount)} ₫';
  }

  /// Formats numbers to VND with pure text e.g. "2,500,000 VND"
  static String formatVndText(num amount) {
    return '${_vndFormat.format(amount)} VND';
  }
}
