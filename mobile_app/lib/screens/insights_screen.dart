import 'package:material_ui/material_ui.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
    required this.apiClient,
    required this.healthStatus,
    required this.isChecking,
    required this.onUpdateUrlAndTest,
  });

  final StudentApiClient apiClient;
  final ApiHealthStatus healthStatus;
  final bool isChecking;
  final ValueChanged<String> onUpdateUrlAndTest;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late final TextEditingController _urlController;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.apiClient.baseUrl);
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final statusColor =
        widget.healthStatus.isOnline ? AppColors.emerald : AppColors.amber;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isWide ? 24 : 16,
        isWide ? 24 : 12,
        isWide ? 24 : 16,
        isWide ? 28 : 104,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StaggeredEntrance(
                delay: const Duration(milliseconds: 40),
                child: GlassCard(
                  enableBlur: true,
                  highlighted: _isFocused,
                  glowColor: AppColors.cyanBright,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.dns_rounded,
                            color: AppColors.cyanBright,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Flask Backend Connection',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Point the app to your running Flask server (use http://127.0.0.1:5000 on Windows/Web or http://10.0.2.2:5000 on Android Emulator).',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _urlController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Backend Base URL',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.cyanBright,
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AnimatedGradientButton(
                            label: 'Save & Test /health',
                            icon: Icons.network_check_rounded,
                            isLoading: widget.isChecking,
                            compact: true,
                            onPressed: () => widget
                                .onUpdateUrlAndTest(_urlController.text),
                          ),
                          AnimatedContainer(
                            duration: AppMotion.effectiveDuration(
                                context, AppMotion.fast),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: statusColor.withValues(alpha: 0.14),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.healthStatus.isOnline
                                      ? Icons.check_circle_rounded
                                      : Icons.warning_amber_rounded,
                                  color: statusColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.healthStatus.message,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              StaggeredEntrance(
                delay: const Duration(milliseconds: 140),
                child: GlassCard(
                  glowColor: AppColors.violet,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.model_training_rounded,
                            color: AppColors.violetBright,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Trained ML Pipeline Overview',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _SpecRow('Dataset', 'dataset/student-mat.csv (395 students, Math)'),
                      _SpecRow('Algorithm', 'RandomForestRegressor (n_estimators=200, random_state=42)'),
                      _SpecRow('Preprocessing', 'ColumnTransformer (Median Imputer + OneHotEncoder)'),
                      _SpecRow('Evaluation (20% Split)', 'MAE: 1.0252  •  RMSE: 1.7052  •  R²: 0.8582'),
                      _SpecRow(
                        '10 Input Features',
                        'G1, G2, absences, studytime, failures, age, schoolsup, activities, internet, higher',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.cyanBright,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
