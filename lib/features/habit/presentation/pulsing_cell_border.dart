import 'package:flutter/material.dart';

class PulsingCellBorder extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool enabled;
  final BoxShape shape;
  final BorderRadius? borderRadius;

  const PulsingCellBorder({
    super.key,
    required this.child,
    required this.color,
    this.enabled = true,
    this.shape = BoxShape.circle,
    this.borderRadius,
  });

  @override
  State<PulsingCellBorder> createState() => _PulsingCellBorderState();
}

class _PulsingCellBorderState extends State<PulsingCellBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 3.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle ? null : widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: _animation.value * 2,
                spreadRadius: _animation.value / 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
