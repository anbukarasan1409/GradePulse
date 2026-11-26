import 'package:material_ui/material_ui.dart';

import '../models/student_input.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import 'prediction_result_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.healthStatus,
    required this.isCheckingHealth,
    required this.onRefreshHealth,
    required this.history,
    required this.onStartPrediction,
    required this.onUsePreset,
  });

  final ApiHealthStatus healthStatus;
  final bool isCheckingHealth;
  final VoidCallback onRefreshHealth;
  final List<PredictionResult> history;
  final VoidCallback onStartPrediction;
  final ValueChanged<StudentInput> onUsePreset;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 960;
    final isMedium = width >= 620;

    final latestPrediction = history.isNotEmpty ? history.first.predictedG3 : 15.77;
    final hasSessionPredictions = history.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isWide ? 24 : 16,
        isWide ? 24 : 12,
        isWide ? 24 : 16,
        isWide ? 28 : 104,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Banner
              StaggeredEntrance(
                delay: const Duration(milliseconds: 40),
                child: _HeroBanner(
                  healthStatus: healthStatus,
                  isCheckingHealth: isCheckingHealth,
                  onRefreshHealth: onRefreshHealth,
                  onStartPrediction: onStartPrediction,
                  isWide: isMedium,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Staggered KPI Stat Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 540
                          ? 2
                          : 1;
                  const spacing = 14.0;
                  final cardWidth =
                      (constraints.maxWidth - spacing * (cols - 1)) / cols;

                  final stats = [
                    _StatSpec(
                      title: 'Model Fit (R²)',
                      value: 85.8,
                      decimals: 1,
                      suffix: '%',
                      subtitle: 'Explained grade variance',
                      icon: Icons.insights_rounded,
                      accent: AppColors.cyanBright,
                    ),
                    _StatSpec(
                      title: 'Mean Abs. Error',
                      value: 1.03,
                      decimals: 2,
                      suffix: ' pts',
                      subtitle: 'On 0–20 G3 grade scale',
                      icon: Icons.track_changes_rounded,
                      accent: AppColors.electricBlueBright,
                    ),
                    _StatSpec(
                      title: 'Input Features',
                      value: 10,
                      decimals: 0,
                      suffix: ' cols',
                      subtitle: '6 numeric + 4 binary',
                      icon: Icons.tune_rounded,
                      accent: AppColors.violetBright,
                    ),
                    _StatSpec(
                      title: hasSessionPredictions
                          ? 'Latest Prediction'
                          : 'Sample Benchmark',
                      value: latestPrediction,
                      decimals: 2,
                      suffix: ' /20',
                      subtitle: hasSessionPredictions
                          ? '${history.length} run${history.length == 1 ? '' : 's'} this session'
                          : 'Validated API output',
                      icon: Icons.school_rounded,
                      accent: AppColors.emerald,
                    ),
                  ];

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(stats.length, (i) {
                      final s = stats[i];
                      return SizedBox(
                        width: cardWidth,
                        child: StaggeredEntrance(
                          delay: Duration(milliseconds: 90 + i * 65),
                          child: _KpiStatCard(spec: s),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Feature Importance + Presets / Recent History
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: StaggeredEntrance(
                        delay: const Duration(milliseconds: 340),
                        child: const _FeatureImportanceCard(),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 5,
                      child: StaggeredEntrance(
                        delay: const Duration(milliseconds: 410),
                        child: _QuickPresetsAndHistory(
                          history: history,
                          onUsePreset: onUsePreset,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                StaggeredEntrance(
                  delay: const Duration(milliseconds: 330),
                  child: const _FeatureImportanceCard(),
                ),
                const SizedBox(height: 16),
                StaggeredEntrance(
                  delay: const Duration(milliseconds: 390),
                  child: _QuickPresetsAndHistory(
                    history: history,
                    onUsePreset: onUsePreset,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.healthStatus,
    required this.isCheckingHealth,
    required this.onRefreshHealth,
    required this.onStartPrediction,
    required this.isWide,
  });

  final ApiHealthStatus healthStatus;
  final bool isCheckingHealth;
  final VoidCallback onRefreshHealth;
  final VoidCallback onStartPrediction;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        healthStatus.isOnline ? AppColors.emerald : AppColors.amber;

    return GlassCard(
      enableBlur: true,
      glowColor: AppColors.electricBlue,
      padding: EdgeInsets.all(isWide ? 28 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricBlue.withValues(alpha: 0.25),
                      AppColors.violet.withValues(alpha: 0.22),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.cyanBright.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: AppColors.cyanBright,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'RANDOM FOREST REGRESSOR • 200 TREES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.cyanBright,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: isCheckingHealth ? null : onRefreshHealth,
                borderRadius: BorderRadius.circular(30),
                child: AnimatedContainer(
                  duration: AppMotion.effectiveDuration(context, AppMotion.fast),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: statusColor.withValues(alpha: 0.14),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCheckingHealth)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: statusColor,
                          ),
                        )
                      else
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.75),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isCheckingHealth ? 'Checking API...' : healthStatus.message,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: isWide ? 1 : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.textPrimary,
                          AppColors.cyanBright,
                          AppColors.electricBlueBright,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Student Performance Prediction',
                        style: TextStyle(
                          fontSize: isWide ? 30 : 24,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Forecast final Math grades (G3 on a 0–20 scale) from period grades, attendance, study habits, and academic support signals.',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isWide ? 24 : 0, height: isWide ? 0 : 18),
              AnimatedGradientButton(
                label: 'New Prediction',
                icon: Icons.rocket_launch_rounded,
                onPressed: onStartPrediction,
                gradient: AppColors.heroGradient,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatSpec {
  const _StatSpec({
    required this.title,
    required this.value,
    required this.decimals,
    required this.suffix,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final double value;
  final int decimals;
  final String suffix;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class _KpiStatCard extends StatelessWidget {
  const _KpiStatCard({required this.spec});

  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: spec.accent,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  spec.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: spec.accent.withValues(alpha: 0.16),
                  border: Border.all(
                    color: spec.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(spec.icon, color: spec.accent, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedCounterText(
            value: spec.value,
            decimals: spec.decimals,
            suffix: spec.suffix,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            spec.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureImportanceCard extends StatelessWidget {
  const _FeatureImportanceCard();

  static const _items = [
    ('Second Period Grade (G2)', 0.80, AppColors.cyanBright),
    ('School Absences', 0.12, AppColors.electricBlueBright),
    ('First Period Grade (G1)', 0.04, AppColors.violetBright),
    ('Weekly Study Time & Age', 0.025, AppColors.emerald),
    ('Past Failures & Support', 0.015, AppColors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = AppMotion.effectiveDuration(
      context,
      const Duration(milliseconds: 950),
    );

    return GlassCard(
      glowColor: AppColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.cyanBright, size: 21),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Key Grade Drivers',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Relative signal strength learned from 395 Math student records.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ...List.generate(_items.length, (i) {
            final (label, weight, color) = _items[i];
            final pct = weight * 100;
            return Padding(
              padding: EdgeInsets.only(bottom: i == _items.length - 1 ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      AnimatedCounterText(
                        value: pct,
                        decimals: 1,
                        suffix: '%',
                        duration: effectiveDuration,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 8,
                      color: Colors.white.withValues(alpha: 0.08),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: weight),
                        duration: effectiveDuration,
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: val.clamp(0.03, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.75),
                                    color,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.45),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuickPresetsAndHistory extends StatelessWidget {
  const _QuickPresetsAndHistory({
    required this.history,
    required this.onUsePreset,
  });

  final List<PredictionResult> history;
  final ValueChanged<StudentInput> onUsePreset;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.violetBright, size: 21),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quick Profiles & Recent Runs',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Load a sample student profile into the predictor in one click.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PresetChip(
                label: 'High Achiever',
                color: AppColors.cyanBright,
                icon: Icons.emoji_events_rounded,
                onTap: () => onUsePreset(StudentInput.highAchiever()),
              ),
              _PresetChip(
                label: 'Balanced Student',
                color: AppColors.electricBlueBright,
                icon: Icons.person_rounded,
                onTap: () => onUsePreset(StudentInput.defaults()),
              ),
              _PresetChip(
                label: 'Needs Support',
                color: AppColors.amber,
                icon: Icons.support_rounded,
                onTap: () => onUsePreset(StudentInput.needsSupport()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 14),
          const Text(
            'SESSION HISTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No predictions run yet in this session. Tap "New Prediction" or pick a preset above.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...history.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          SlideScalePageRoute<void>(
                            builder: (_) => PredictionResultScreen.completed(
                              result: item,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: item.accentColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: item.accentColor.withValues(alpha: 0.16),
                              ),
                              child: Text(
                                item.predictedG3.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: item.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'G1: ${item.input.g1.toInt()} • G2: ${item.input.g2.toInt()} • Abs: ${item.input.absences}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatefulWidget {
  const _PresetChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PresetChip> createState() => _PresetChipState();
}

class _PresetChipState extends State<_PresetChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.effectiveDuration(context, AppMotion.fast);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: duration,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.color.withValues(alpha: _hovered ? 0.22 : 0.12),
            border: Border.all(
              color: widget.color.withValues(alpha: _hovered ? 0.65 : 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
