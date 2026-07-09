import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// Reusable card component for CitApps.
///
/// Provides consistent padding, border radius, and styling
/// for content cards throughout the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? borderSide;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      shape: borderSide != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              side: borderSide!,
            )
          : null,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSizes.md),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: card,
      );
    }

    return card;
  }
}
