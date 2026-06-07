import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Lightweight shimmer band (no extra packages).
class ShimmerWave extends StatefulWidget {
  const ShimmerWave({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<ShimmerWave> createState() => _ShimmerWaveState();
}

class _ShimmerWaveState extends State<ShimmerWave> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

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

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        final double angle = -math.pi / 6;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final double dx = bounds.width * (t * 2 - 0.5);

            return LinearGradient(
              begin: Alignment(math.cos(angle), math.sin(angle)),
              end: Alignment(-math.cos(angle), -math.sin(angle)),
              colors: <Color>[
                AppColors.surface,
                AppColors.text.withValues(alpha: 0.10),
                AppColors.surface,
              ],
              stops: const <double>[0.35, 0.50, 0.65],
              transform: GradientTranslation(dx, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class GradientTranslation extends GradientTransform {
  const GradientTranslation(this.dx, this.dy);

  final double dx;
  final double dy;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, dy, 0);
  }
}
