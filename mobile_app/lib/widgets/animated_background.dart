import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

/// Subtle dark-navy canvas with slowly drifting electric-blue, cyan, and
/// violet radial gradient orbs. Wrapped in a RepaintBoundary for 60 FPS
/// performance and pauses automatically when reduced motion is enabled.
class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotion(context)) {
      _controller.stop();
      _controller.value = 0.25;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navyDeep,
                  Color(0xFF081024),
                  Color(0xFF0A1430),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final angle = _controller.value * 2 * math.pi;
                return CustomPaint(
                  painter: _FloatingOrbsPainter(phase: angle),
                );
              },
            ),
          ),
        ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _FloatingOrbsPainter extends CustomPainter {
  const _FloatingOrbsPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    _drawOrb(
      canvas: canvas,
      center: Offset(
        size.width * (0.16 + 0.05 * math.sin(phase)),
        size.height * (0.18 + 0.04 * math.cos(phase)),
      ),
      radius: math.max(size.width, size.height) * 0.34,
      color: AppColors.electricBlue.withValues(alpha: 0.16),
    );

    _drawOrb(
      canvas: canvas,
      center: Offset(
        size.width * (0.85 + 0.05 * math.cos(phase * 0.9)),
        size.height * (0.24 + 0.06 * math.sin(phase * 0.8)),
      ),
      radius: math.max(size.width, size.height) * 0.30,
      color: AppColors.cyan.withValues(alpha: 0.13),
    );

    _drawOrb(
      canvas: canvas,
      center: Offset(
        size.width * (0.55 + 0.06 * math.sin(phase + 1.4)),
        size.height * (0.84 + 0.04 * math.cos(phase + 0.7)),
      ),
      radius: math.max(size.width, size.height) * 0.32,
      color: AppColors.violet.withValues(alpha: 0.14),
    );
  }

  void _drawOrb({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: color.a * 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _FloatingOrbsPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
