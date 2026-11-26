import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

/// Custom PageRouteBuilder providing smooth horizontal slide + subtle fade &
/// scale transitions between screens.
class SlideScalePageRoute<T> extends PageRouteBuilder<T> {
  SlideScalePageRoute({
    required WidgetBuilder builder,
    super.settings,
  }) : super(
          transitionDuration: AppMotion.routeTransition,
          reverseTransitionDuration: AppMotion.medium,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (AppMotion.reduceMotion(context)) {
              return child;
            }
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0.08, 0.0),
              end: Offset.zero,
            ).animate(curved);
            final scale = Tween<double>(
              begin: 0.97,
              end: 1.0,
            ).animate(curved);

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: scale,
                  child: child,
                ),
              ),
            );
          },
        );
}

/// Staggered slide-in and fade-in entrance wrapper for cards and sections.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 18),
    this.duration = AppMotion.slow,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curve = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standardCurve,
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    if (AppMotion.reduceMotion(context)) {
      _controller.value = 1.0;
      return;
    }

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
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
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Glassmorphic card with smooth hover elevation, border glow, and optional
/// tap press scale & ripple feedback.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
    this.onTap,
    this.glowColor = AppColors.cyan,
    this.enableBlur = false,
    this.highlighted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color glowColor;
  final bool enableBlur;
  final bool highlighted;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    final duration = AppMotion.effectiveDuration(context, AppMotion.fast);
    final isInteractive = widget.onTap != null;
    final activeGlow = _hovered || widget.highlighted;
    final scale = (!reduce && _pressed && isInteractive)
        ? 0.985
        : (!reduce && _hovered)
            ? 1.008
            : 1.0;

    final cardDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          activeGlow
              ? AppColors.navyElevated.withValues(alpha: 0.88)
              : AppColors.navyCard.withValues(alpha: 0.78),
          AppColors.navySurface.withValues(alpha: 0.72),
        ],
      ),
      border: Border.all(
        color: activeGlow
            ? widget.glowColor.withValues(alpha: 0.52)
            : Colors.white.withValues(alpha: 0.11),
        width: activeGlow ? 1.3 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: activeGlow ? 0.36 : 0.24),
          blurRadius: activeGlow ? 26 : 16,
          offset: Offset(0, activeGlow ? 12 : 8),
        ),
        if (activeGlow)
          BoxShadow(
            color: widget.glowColor.withValues(alpha: 0.16),
            blurRadius: 24,
            spreadRadius: -2,
          ),
      ],
    );

    Widget inner = AnimatedContainer(
      duration: duration,
      curve: AppMotion.standardCurve,
      decoration: cardDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: isInteractive
              ? (val) => setState(() => _pressed = val)
              : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: widget.glowColor.withValues(alpha: 0.14),
          highlightColor: widget.glowColor.withValues(alpha: 0.06),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.enableBlur) {
      inner = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: inner,
        ),
      );
    }

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: AnimatedScale(
        scale: scale,
        duration: duration,
        curve: AppMotion.standardCurve,
        child: inner,
      ),
    );
  }
}

/// Primary gradient CTA button with scale feedback, hover glow, ripple, and
/// smooth icon/loading transitions.
class AnimatedGradientButton extends StatefulWidget {
  const AnimatedGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradient = AppColors.primaryGradient,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Gradient gradient;
  final bool compact;

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final reduce = AppMotion.reduceMotion(context);
    final duration = AppMotion.effectiveDuration(context, AppMotion.fast);
    final scale = (!reduce && _pressed && enabled)
        ? 0.965
        : (!reduce && _hovered && enabled)
            ? 1.02
            : 1.0;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: AnimatedScale(
        scale: scale,
        duration: duration,
        curve: AppMotion.standardCurve,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.standardCurve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: enabled
                ? widget.gradient
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.electricBlue
                          .withValues(alpha: _hovered ? 0.48 : 0.30),
                      blurRadius: _hovered ? 22 : 14,
                      offset: Offset(0, _hovered ? 8 : 5),
                    ),
                    BoxShadow(
                      color: AppColors.cyan
                          .withValues(alpha: _hovered ? 0.28 : 0.14),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              onHighlightChanged: (v) => setState(() => _pressed = v),
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.22),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 18 : 24,
                  vertical: widget.compact ? 12 : 15,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: duration,
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: widget.isLoading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : widget.icon != null
                              ? Icon(
                                  widget.icon,
                                  key: ValueKey(widget.icon),
                                  size: 19,
                                  color: Colors.white,
                                )
                              : const SizedBox.shrink(),
                    ),
                    if (widget.icon != null || widget.isLoading)
                      const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: enabled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w700,
                        fontSize: widget.compact ? 14 : 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth number counter powered by TweenAnimationBuilder.
class AnimatedCounterText extends StatelessWidget {
  const AnimatedCounterText({
    super.key,
    required this.value,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = AppMotion.countUp,
  });

  final double value;
  final int decimals;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = AppMotion.effectiveDuration(context, duration);
    if (effectiveDuration == Duration.zero) {
      return Text(
        '$prefix${value.toStringAsFixed(decimals)}$suffix',
        style: style,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: effectiveDuration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          '$prefix${animatedValue.toStringAsFixed(decimals)}$suffix',
          style: style,
        );
      },
    );
  }
}
