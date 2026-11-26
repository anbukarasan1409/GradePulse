import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/student_input.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_widgets.dart';

class PredictionResultScreen extends StatefulWidget {
  const PredictionResultScreen.runPrediction({
    super.key,
    required StudentApiClient this.apiClient,
    required StudentInput this.input,
  }) : precomputed = null;

  const PredictionResultScreen.completed({
    super.key,
    required PredictionResult result,
  })  : apiClient = null,
        input = null,
        precomputed = result;

  final StudentApiClient? apiClient;
  final StudentInput? input;
  final PredictionResult? precomputed;

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _loadingController;
  late final AnimationController _gaugeController;

  PredictionResult? _result;
  String? _errorMessage;
  bool _isLoading = true;
  int _loadingStep = 0;
  Timer? _stepTimer;

  static const _loadingMessages = [
    'Validating 10 student features...',
    'Running 200 Random Forest decision trees...',
    'Calibrating final G3 prediction...',
  ];

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _gaugeController = AnimationController(
      vsync: this,
      duration: AppMotion.countUp,
    );

    if (widget.precomputed != null) {
      _result = widget.precomputed;
      _isLoading = false;
      _gaugeController.forward();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startPrediction();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && !AppMotion.reduceMotion(context)) {
      if (!_loadingController.isAnimating) {
        _loadingController.repeat();
      }
    } else {
      _loadingController.stop();
    }
    if (AppMotion.reduceMotion(context) && _result != null) {
      _gaugeController.value = 1.0;
    }
  }

  Future<void> _startPrediction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingStep = 0;
    });

    if (!mounted) return;
    if (!AppMotion.reduceMotion(context)) {
      _loadingController.repeat();
    }

    _stepTimer?.cancel();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 420), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _loadingStep = (_loadingStep + 1) % _loadingMessages.length;
      });
    });

    try {
      // Brief minimum animation beat so the glowing loader feels intentional.
      final apiFuture = widget.apiClient!.predict(widget.input!);
      final minBeat = Future<void>.delayed(
        AppMotion.reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 850),
      );
      final results = await Future.wait([apiFuture, minBeat]);
      final prediction = results.first as PredictionResult;

      if (!mounted) return;
      _stepTimer?.cancel();
      _loadingController.stop();
      setState(() {
        _result = prediction;
        _isLoading = false;
      });
      if (AppMotion.reduceMotion(context)) {
        _gaugeController.value = 1.0;
      } else {
        _gaugeController.forward(from: 0.0);
      }
    } catch (e) {
      if (!mounted) return;
      _stepTimer?.cancel();
      _loadingController.stop();
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _loadingController.dispose();
    _gaugeController.dispose();
    super.dispose();
  }

  void _closeWithResult() {
    Navigator.of(context).pop(_result);
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.effectiveDuration(context, AppMotion.medium);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _closeWithResult();
        }
      },
      child: Scaffold(
        body: AnimatedMeshBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _closeWithResult,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Prediction Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: AnimatedSwitcher(
                          duration: duration,
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, anim) {
                            if (AppMotion.reduceMotion(context)) return child;
                            return FadeTransition(
                              opacity: anim,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.94, end: 1.0)
                                    .animate(anim),
                                child: child,
                              ),
                            );
                          },
                          child: _isLoading
                              ? _buildLoadingView()
                              : _errorMessage != null
                                  ? _buildErrorView()
                                  : _buildResultView(_result!),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return GlassCard(
      key: const ValueKey('loading'),
      enableBlur: true,
      glowColor: AppColors.cyanBright,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 148,
            height: 148,
            child: AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GlowingProgressPainter(
                    progress: _loadingController.value,
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.electricBlue.withValues(alpha: 0.35),
                        AppColors.cyan.withValues(alpha: 0.22),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.cyanBright,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Analyzing Student Profile',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: AppMotion.effectiveDuration(context, AppMotion.fast),
            child: Text(
              _loadingMessages[_loadingStep],
              key: ValueKey(_loadingStep),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.cyanBright,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return GlassCard(
      key: const ValueKey('error'),
      enableBlur: true,
      glowColor: AppColors.rose,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.rose.withValues(alpha: 0.16),
              border: Border.all(color: AppColors.rose.withValues(alpha: 0.5)),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.rose,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Unable to Reach Prediction API',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              AnimatedGradientButton(
                label: 'Retry Prediction',
                icon: Icons.refresh_rounded,
                onPressed: _startPrediction,
              ),
              OutlinedButton(
                onPressed: _closeWithResult,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Form'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(PredictionResult result) {
    final accent = result.accentColor;
    final insights = result.buildInsights();

    return Column(
      key: const ValueKey('result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggeredEntrance(
          delay: const Duration(milliseconds: 40),
          child: GlassCard(
            enableBlur: true,
            glowColor: accent,
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: accent.withValues(alpha: 0.16),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    result.performanceBand.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 210,
                  height: 210,
                  child: AnimatedBuilder(
                    animation: _gaugeController,
                    builder: (context, child) {
                      final eased = Curves.easeOutCubic
                          .transform(_gaugeController.value);
                      return CustomPaint(
                        painter: _GradeGaugePainter(
                          fraction: (result.predictedG3 / 20.0) * eased,
                          accent: accent,
                        ),
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'PREDICTED G3',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedCounterText(
                          value: result.predictedG3,
                          decimals: 2,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: accent,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'out of 20.00',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _SnapshotPill(
                      label: 'G1: ${result.input.g1.toStringAsFixed(0)}/20',
                    ),
                    _SnapshotPill(
                      label: 'G2: ${result.input.g2.toStringAsFixed(0)}/20',
                    ),
                    _SnapshotPill(label: 'Absences: ${result.input.absences}'),
                    _SnapshotPill(label: 'API: ${result.responseMs} ms'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        StaggeredEntrance(
          delay: const Duration(milliseconds: 180),
          child: GlassCard(
            glowColor: AppColors.electricBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.cyanBright,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Personalized Insights',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...insights.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cyanBright,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedGradientButton(
                    label: 'Done & Save to History',
                    icon: Icons.check_rounded,
                    onPressed: _closeWithResult,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SnapshotPill extends StatelessWidget {
  const _SnapshotPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _GlowingProgressPainter extends CustomPainter {
  const _GlowingProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 12;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final startAngle = progress * 2 * math.pi - math.pi / 2;
    const sweep = 1.45 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: const [
          AppColors.electricBlue,
          AppColors.cyanBright,
          AppColors.violetBright,
          AppColors.electricBlue,
        ],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: const [
          AppColors.electricBlue,
          AppColors.cyanBright,
          AppColors.violetBright,
          AppColors.electricBlue,
        ],
        transform: GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;
    canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _GradeGaugePainter extends CustomPainter {
  const _GradeGaugePainter({
    required this.fraction,
    required this.accent,
  });

  final double fraction;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const startAngle = math.pi * 0.75;
    const totalSweep = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    final sweep = totalSweep * fraction.clamp(0.0, 1.0);
    if (sweep <= 0) return;

    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.electricBlue, accent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13;
    canvas.drawArc(rect, startAngle, sweep, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GradeGaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction || oldDelegate.accent != accent;
  }
}
