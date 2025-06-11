import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingFoodIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double left;
  final double top;
  final Duration delay;

  const FloatingFoodIcon({
    Key? key,
    required this.icon,
    required this.color,
    this.size = 30,
    required this.left,
    required this.top,
    required this.delay,
  }) : super(key: key);

  @override
  State<FloatingFoodIcon> createState() => _FloatingFoodIconState();
}

class _FloatingFoodIconState extends State<FloatingFoodIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _positionAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          top: widget.top + _positionAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * math.pi,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SparkleEffect extends StatefulWidget {
  final double size;
  final Color color;
  final double left;
  final double top;

  const SparkleEffect({
    Key? key,
    this.size = 10,
    required this.color,
    required this.left,
    required this.top,
  }) : super(key: key);

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          top: widget.top,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                Icons.star,
                color: widget.color,
                size: widget.size,
              ),
            ),
          ),
        );
      },
    );
  }
}
