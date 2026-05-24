import 'dart:math';
import 'package:flutter/material.dart';

class AmbientGlowWrapper extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final bool isDark;

  const AmbientGlowWrapper({
    super.key,
    required this.child,
    required this.enabled,
    required this.isDark,
  });

  @override
  State<AmbientGlowWrapper> createState() => _AmbientGlowWrapperState();
}

class _AmbientGlowWrapperState extends State<AmbientGlowWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final colors = widget.isDark
        ? [const Color(0xFF00FFFF), const Color(0xFFFF007F), const Color(0xFF00FFFF)]
        : [const Color(0xFFE0007A), const Color(0xFFFF5E00), const Color(0xFFE0007A)];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * pi;
        final begin = Alignment(
          cos(angle),
          sin(angle),
        );
        final end = Alignment(
          cos(angle + pi),
          sin(angle + pi),
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? colors[1] : colors[0]).withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: colors,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
