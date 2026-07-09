/// Useful Dart extension methods used across CitApps.
library;

import 'package:flutter/material.dart';

/// Extensions on [String].
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Returns initials from a full name. "John Doe" → "JD"
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

/// Extensions on [BuildContext] for common shortcuts.
extension BuildContextExtension on BuildContext {
  /// Access the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Access the current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Access the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access the [MediaQueryData].
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Shows a [SnackBar] with a message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}

/// Extensions on [DateTime].
extension DateTimeExtension on DateTime {
  /// Returns only the date part (no time).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Checks if this date is the same day as another.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
