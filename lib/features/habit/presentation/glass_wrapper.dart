import 'dart:ui';
import 'package:flutter/material.dart';

class GlassWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final BorderRadius? borderRadius;

  const GlassWrapper({
    super.key,
    required this.child,
    required this.enabled,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final radius = borderRadius ?? BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
