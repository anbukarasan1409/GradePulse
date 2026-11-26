import 'package:material_ui/material_ui.dart';

import '../models/student_input.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import 'prediction_result_screen.dart';

class PredictFormScreen extends StatefulWidget {
  const PredictFormScreen({
    super.key,
    required this.apiClient,
    required this.initialInput,
    required this.onPredictionCompleted,
  });

  final StudentApiClient apiClient;
  final StudentInput initialInput;
  final ValueChanged<PredictionResult> onPredictionCompleted;

  @override
  State<PredictFormScreen> createState() => _PredictFormScreenState();
}

class _PredictFormScreenState extends State<PredictFormScreen> {
  late StudentInput _input;
  int _currentSection = 0;
  int _previousSection = 0;
  bool _dropdownExpanded = false;
  int? _focusedFieldIndex;
  String? _validationError;

  static const _sections = [
    ('Academic Grades', Icons.grade_rounded),
    ('Study & Profile', Icons.schedule_rounded),
    ('Support & Goals', Icons.psychology_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _input = widget.initialInput;
  }

  @override
  void didUpdateWidget(covariant PredictFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialInput != widget.initialInput) {
      setState(() {
        _input = widget.initialInput;
        _validationError = null;
      });
    }
  }

  void _goToSection(int index) {
    if (index == _currentSection) return;
    setState(() {
      _previousSection = _currentSection;
      _currentSection = index;
      _dropdownExpanded = false;
      _focusedFieldIndex = null;
    });
  }

  bool _validateCurrentInputs() {
    if (_input.g1 < 0 || _input.g1 > 20 || _input.g2 < 0 || _input.g2 > 20) {
      setState(() => _validationError = 'G1 and G2 grades must stay between 0 and 20.');
      return false;
    }
    if (_input.absences < 0 || _input.absences > 365) {
      setState(() => _validationError = 'Absences must be between 0 and 365.');
      return false;
    }
    if (_input.age < 10 || _input.age > 100) {
      setState(() => _validationError = 'Age must be between 10 and 100.');
      return false;
    }
    setState(() => _validationError = null);
    return true;
  }

  Future<void> _submitPrediction() async {
    if (!_validateCurrentInputs()) return;
    final result = await Navigator.of(context).push<PredictionResult>(
      SlideScalePageRoute<PredictionResult>(
        builder: (_) => PredictionResultScreen.runPrediction(
          apiClient: widget.apiClient,
          input: _input,
        ),
      ),
    );
    if (result != null && mounted) {
      widget.onPredictionCompleted(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final duration = AppMotion.effectiveDuration(context, AppMotion.medium);
    final movingForward = _currentSection >= _previousSection;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isWide ? 24 : 16,
        isWide ? 24 : 12,
        isWide ? 24 : 16,
        isWide ? 28 : 108,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StaggeredEntrance(
                delay: const Duration(milliseconds: 30),
                child: GlassCard(
                  enableBlur: true,
                  glowColor: AppColors.electricBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student Assessment Form',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Complete the 3 short sections to predict final Math grade (G3).',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MiniPresetButton(
                                label: 'High Achiever',
                                onTap: () => setState(
                                    () => _input = StudentInput.highAchiever()),
                              ),
                              _MiniPresetButton(
                                label: 'Reset',
                                onTap: () => setState(
                                    () => _input = StudentInput.defaults()),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Interactive Section Tabs + Progress Track
                      Row(
                        children: List.generate(_sections.length, (index) {
                          final (label, icon) = _sections[index];
                          final active = index == _currentSection;
                          final completed = index < _currentSection;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _goToSection(index),
                              child: AnimatedContainer(
                                duration: duration,
                                curve: AppMotion.standardCurve,
                                margin: EdgeInsets.only(
                                  right: index == _sections.length - 1 ? 0 : 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: active
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.electricBlue
                                                .withValues(alpha: 0.30),
                                            AppColors.cyan
                                                .withValues(alpha: 0.16),
                                          ],
                                        )
                                      : null,
                                  color: active
                                      ? null
                                      : Colors.white.withValues(alpha: 0.04),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.cyanBright
                                            .withValues(alpha: 0.65)
                                        : completed
                                            ? AppColors.emerald
                                                .withValues(alpha: 0.45)
                                            : Colors.white
                                                .withValues(alpha: 0.09),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      completed
                                          ? Icons.check_circle_rounded
                                          : icon,
                                      size: 17,
                                      color: active
                                          ? AppColors.cyanBright
                                          : completed
                                              ? AppColors.emerald
                                              : AppColors.textMuted,
                                    ),
                                    if (width >= 520) ...[
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          label,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: active
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: active
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AnimatedContainer(
                    duration: duration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.rose.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.rose.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.rose,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Smooth Animated Transition Between Form Sections
              AnimatedSwitcher(
                duration: duration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  if (AppMotion.reduceMotion(context)) {
                    return child;
                  }
                  final beginOffset = Offset(movingForward ? 0.06 : -0.06, 0.0);
                  final offsetAnim = Tween<Offset>(
                    begin: beginOffset,
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnim,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentSection),
                  child: _buildCurrentSection(context),
                ),
              ),

              const SizedBox(height: 18),

              // Navigation Footer Controls
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentSection > 0)
                      TextButton.icon(
                        onPressed: () => _goToSection(_currentSection - 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Previous'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      )
                    else
                      Text(
                        'Step ${_currentSection + 1} of ${_sections.length}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (_currentSection < _sections.length - 1)
                      AnimatedGradientButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        compact: true,
                        onPressed: () {
                          if (_validateCurrentInputs()) {
                            _goToSection(_currentSection + 1);
                          }
                        },
                      )
                    else
                      AnimatedGradientButton(
                        label: 'Predict Final Grade',
                        icon: Icons.auto_awesome_rounded,
                        gradient: AppColors.heroGradient,
                        onPressed: _submitPrediction,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSection(BuildContext context) {
    switch (_currentSection) {
      case 0:
        return _buildAcademicSection();
      case 1:
        return _buildStudyProfileSection();
      default:
        return _buildSupportGoalsSection();
    }
  }

  Widget _buildAcademicSection() {
    return Column(
      children: [
        _FocusGlassField(
          focused: _focusedFieldIndex == 0,
          glowColor: AppColors.cyanBright,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldHeader(
                title: 'First Period Grade (G1)',
                subtitle: '0 – 20 grading scale',
                badgeValue: '${_input.g1.toStringAsFixed(0)} / 20',
                badgeColor: AppColors.cyanBright,
              ),
              Slider(
                value: _input.g1,
                min: 0,
                max: 20,
                divisions: 20,
                onChangeStart: (_) => setState(() => _focusedFieldIndex = 0),
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(g1: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FocusGlassField(
          focused: _focusedFieldIndex == 1,
          glowColor: AppColors.electricBlueBright,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldHeader(
                title: 'Second Period Grade (G2)',
                subtitle: 'Strongest predictor of final G3',
                badgeValue: '${_input.g2.toStringAsFixed(0)} / 20',
                badgeColor: AppColors.electricBlueBright,
              ),
              Slider(
                value: _input.g2,
                min: 0,
                max: 20,
                divisions: 20,
                onChangeStart: (_) => setState(() => _focusedFieldIndex = 1),
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(g2: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FocusGlassField(
          focused: _focusedFieldIndex == 2,
          glowColor: AppColors.violetBright,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldHeader(
                title: 'School Absences',
                subtitle: 'Total missed classes (0 – 93)',
                badgeValue: '${_input.absences} days',
                badgeColor: AppColors.violetBright,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StepIconButton(
                    icon: Icons.remove_rounded,
                    onTap: _input.absences > 0
                        ? () => setState(() {
                              _focusedFieldIndex = 2;
                              _input = _input.copyWith(
                                  absences: _input.absences - 1);
                            })
                        : null,
                  ),
                  Expanded(
                    child: Slider(
                      value: _input.absences.toDouble().clamp(0, 75),
                      min: 0,
                      max: 75,
                      divisions: 75,
                      onChangeStart: (_) =>
                          setState(() => _focusedFieldIndex = 2),
                      onChanged: (v) => setState(
                          () => _input = _input.copyWith(absences: v.round())),
                    ),
                  ),
                  _StepIconButton(
                    icon: Icons.add_rounded,
                    onTap: _input.absences < 93
                        ? () => setState(() {
                              _focusedFieldIndex = 2;
                              _input = _input.copyWith(
                                  absences: _input.absences + 1);
                            })
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FocusGlassField(
          focused: _focusedFieldIndex == 3,
          glowColor: AppColors.amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldHeader(
                title: 'Past Class Failures',
                subtitle: 'Number of previously failed classes (0 – 4)',
                badgeValue: '${_input.failures}',
                badgeColor: AppColors.amber,
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (count) {
                  final selected = _input.failures == count;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _focusedFieldIndex = 3;
                        _input = _input.copyWith(failures: count);
                      }),
                      child: AnimatedContainer(
                        duration: AppMotion.effectiveDuration(
                            context, AppMotion.fast),
                        margin: EdgeInsets.only(right: count == 4 ? 0 : 8),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: selected ? AppColors.primaryGradient : null,
                          color: selected
                              ? null
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: selected
                                ? AppColors.cyanBright
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudyProfileSection() {
    final duration = AppMotion.effectiveDuration(context, AppMotion.medium);

    return Column(
      children: [
        // Custom Animated Dropdown Menu for Study Time
        _FocusGlassField(
          focused: _dropdownExpanded || _focusedFieldIndex == 4,
          glowColor: AppColors.cyanBright,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldHeader(
                title: 'Weekly Study Time',
                subtitle: 'Select weekly self-study commitment',
                badgeValue: 'Level ${_input.studytime}',
                badgeColor: AppColors.cyanBright,
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() {
                  _dropdownExpanded = !_dropdownExpanded;
                  _focusedFieldIndex = 4;
                }),
                child: AnimatedContainer(
                  duration: duration,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: _dropdownExpanded
                          ? AppColors.cyanBright.withValues(alpha: 0.75)
                          : Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.cyanBright,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          StudentInput.studyTimeLabel(_input.studytime),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _dropdownExpanded ? 0.5 : 0.0,
                        duration: duration,
                        curve: AppMotion.standardCurve,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: duration,
                curve: AppMotion.standardCurve,
                child: _dropdownExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: List.generate(4, (idx) {
                            final level = idx + 1;
                            final selected = _input.studytime == level;
                            return Padding(
                              padding: EdgeInsets.only(bottom: idx == 3 ? 0 : 6),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setState(() {
                                  _input = _input.copyWith(studytime: level);
                                  _dropdownExpanded = false;
                                }),
                                child: AnimatedContainer(
                                  duration: AppMotion.effectiveDuration(
                                      context, AppMotion.fast),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: selected
                                        ? AppColors.electricBlue
                                            .withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.03),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.cyanBright
                                              .withValues(alpha: 0.55)
                                          : Colors.white
                                              .withValues(alpha: 0.07),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Tier $level',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                          color: selected
                                              ? AppColors.cyanBright
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          StudentInput.studyTimeLabel(level),
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                          color: AppColors.cyanBright,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FocusGlassField(
          focused: _focusedFieldIndex == 5,
          glowColor: AppColors.violetBright,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldHeader(
                title: 'Student Age',
                subtitle: 'Dataset range: 15 – 22 years (supports 10 – 100)',
                badgeValue: '${_input.age} yrs',
                badgeColor: AppColors.violetBright,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StepIconButton(
                    icon: Icons.remove_rounded,
                    onTap: _input.age > 12
                        ? () => setState(() {
                              _focusedFieldIndex = 5;
                              _input = _input.copyWith(age: _input.age - 1);
                            })
                        : null,
                  ),
                  Expanded(
                    child: Slider(
                      value: _input.age.toDouble().clamp(14, 24),
                      min: 14,
                      max: 24,
                      divisions: 10,
                      onChangeStart: (_) =>
                          setState(() => _focusedFieldIndex = 5),
                      onChanged: (v) =>
                          setState(() => _input = _input.copyWith(age: v.round())),
                    ),
                  ),
                  _StepIconButton(
                    icon: Icons.add_rounded,
                    onTap: _input.age < 30
                        ? () => setState(() {
                              _focusedFieldIndex = 5;
                              _input = _input.copyWith(age: _input.age + 1);
                            })
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportGoalsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCols = constraints.maxWidth >= 620;
        final width = twoCols
            ? (constraints.maxWidth - 14) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: width,
              child: _ToggleFeatureCard(
                title: 'School Support',
                subtitle: 'Extra educational support from school (schoolsup)',
                value: _input.schoolsup,
                activeIcon: Icons.support_agent_rounded,
                inactiveIcon: Icons.support_outlined,
                accent: AppColors.cyanBright,
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(schoolsup: v)),
              ),
            ),
            SizedBox(
              width: width,
              child: _ToggleFeatureCard(
                title: 'Extracurricular Activities',
                subtitle: 'Participates in clubs or sports (activities)',
                value: _input.activities,
                activeIcon: Icons.sports_basketball_rounded,
                inactiveIcon: Icons.sports_basketball_outlined,
                accent: AppColors.electricBlueBright,
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(activities: v)),
              ),
            ),
            SizedBox(
              width: width,
              child: _ToggleFeatureCard(
                title: 'Home Internet Access',
                subtitle: 'Reliable internet connection at home (internet)',
                value: _input.internet,
                activeIcon: Icons.wifi_rounded,
                inactiveIcon: Icons.wifi_off_rounded,
                accent: AppColors.emerald,
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(internet: v)),
              ),
            ),
            SizedBox(
              width: width,
              child: _ToggleFeatureCard(
                title: 'Higher Education Goal',
                subtitle: 'Plans to pursue university studies (higher)',
                value: _input.higher,
                activeIcon: Icons.workspace_premium_rounded,
                inactiveIcon: Icons.workspace_premium_outlined,
                accent: AppColors.violetBright,
                onChanged: (v) =>
                    setState(() => _input = _input.copyWith(higher: v)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FocusGlassField extends StatelessWidget {
  const _FocusGlassField({
    required this.focused,
    required this.glowColor,
    required this.child,
  });

  final bool focused;
  final Color glowColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      highlighted: focused,
      glowColor: glowColor,
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

class _FieldHeader extends StatelessWidget {
  const _FieldHeader({
    required this.title,
    required this.subtitle,
    required this.badgeValue,
    required this.badgeColor,
  });

  final String title;
  final String subtitle;
  final String badgeValue;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: AppMotion.effectiveDuration(context, AppMotion.fast),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Container(
            key: ValueKey(badgeValue),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: badgeColor.withValues(alpha: 0.16),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              badgeValue,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: badgeColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleFeatureCard extends StatelessWidget {
  const _ToggleFeatureCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.accent,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.effectiveDuration(context, AppMotion.fast);

    return GlassCard(
      highlighted: value,
      glowColor: accent,
      onTap: () => onChanged(!value),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AnimatedContainer(
            duration: duration,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: value
                  ? accent.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: value
                    ? accent.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                value ? activeIcon : inactiveIcon,
                key: ValueKey(value),
                color: value ? accent : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _StepIconButton extends StatelessWidget {
  const _StepIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        foregroundColor: AppColors.textPrimary,
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

class _MiniPresetButton extends StatelessWidget {
  const _MiniPresetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyanBright,
        side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }
}
