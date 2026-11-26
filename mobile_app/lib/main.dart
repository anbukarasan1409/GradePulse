import 'package:material_ui/material_ui.dart';

import 'models/student_input.dart';
import 'screens/dashboard_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/predict_form_screen.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_background.dart';
import 'widgets/app_navigation.dart';

void main() {
  runApp(const StudentPerformanceApp());
}

class StudentPerformanceApp extends StatelessWidget {
  const StudentPerformanceApp({
    super.key,
    this.apiClient,
    this.checkHealthOnLaunch = true,
  });

  final StudentApiClient? apiClient;
  final bool checkHealthOnLaunch;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GradePulse • Student Performance Prediction',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildDarkTheme(),
      home: AppShell(
        apiClient: apiClient ?? StudentApiClient(),
        checkHealthOnLaunch: checkHealthOnLaunch,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.apiClient,
    this.checkHealthOnLaunch = true,
  });

  final StudentApiClient apiClient;
  final bool checkHealthOnLaunch;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  bool _sidebarCollapsed = false;
  bool _isCheckingHealth = false;

  ApiHealthStatus _healthStatus = const ApiHealthStatus(
    isOnline: false,
    modelLoaded: false,
    message: 'Not Checked',
  );

  StudentInput _draftInput = StudentInput.defaults();
  final List<PredictionResult> _history = [];

  @override
  void initState() {
    super.initState();
    if (widget.checkHealthOnLaunch) {
      _refreshHealth();
    }
  }

  Future<void> _refreshHealth() async {
    setState(() => _isCheckingHealth = true);
    final status = await widget.apiClient.checkHealth();
    if (!mounted) return;
    setState(() {
      _healthStatus = status;
      _isCheckingHealth = false;
    });
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  void _usePreset(StudentInput preset) {
    setState(() {
      _draftInput = preset;
      _previousIndex = _selectedIndex;
      _selectedIndex = 1;
    });
  }

  void _onPredictionCompleted(PredictionResult result) {
    setState(() {
      _history.insert(0, result);
      _draftInput = result.input;
    });
  }

  void _updateUrlAndTest(String url) {
    widget.apiClient.updateBaseUrl(url);
    _refreshHealth();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final transitionDuration =
        AppMotion.effectiveDuration(context, AppMotion.routeTransition);
    final movingForward = _selectedIndex >= _previousIndex;

    final pages = [
      DashboardScreen(
        key: const ValueKey('page-dashboard'),
        healthStatus: _healthStatus,
        isCheckingHealth: _isCheckingHealth,
        onRefreshHealth: _refreshHealth,
        history: _history,
        onStartPrediction: () => _selectTab(1),
        onUsePreset: _usePreset,
      ),
      PredictFormScreen(
        key: const ValueKey('page-predict'),
        apiClient: widget.apiClient,
        initialInput: _draftInput,
        onPredictionCompleted: _onPredictionCompleted,
      ),
      InsightsScreen(
        key: const ValueKey('page-insights'),
        apiClient: widget.apiClient,
        healthStatus: _healthStatus,
        isChecking: _isCheckingHealth,
        onUpdateUrlAndTest: _updateUrlAndTest,
      ),
    ];

    final pageSwitcher = AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        if (AppMotion.reduceMotion(context)) {
          return child;
        }
        final slide = Tween<Offset>(
          begin: Offset(movingForward ? 0.06 : -0.06, 0.0),
          end: Offset.zero,
        ).animate(animation);
        final scale = Tween<double>(begin: 0.985, end: 1.0).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
      child: pages[_selectedIndex],
    );

    if (isDesktop) {
      return Scaffold(
        body: AnimatedMeshBackground(
          child: SafeArea(
            child: Row(
              children: [
                DesktopSideNav(
                  selectedIndex: _selectedIndex,
                  onSelect: _selectTab,
                  collapsed: _sidebarCollapsed,
                  onToggleCollapse: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  healthStatus: _healthStatus,
                ),
                Expanded(child: pageSwitcher),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      drawer: MobileGlassDrawer(
        selectedIndex: _selectedIndex,
        onSelect: _selectTab,
        healthStatus: _healthStatus,
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppColors.heroGradient,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              appNavItems[_selectedIndex].label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh API health',
            onPressed: _isCheckingHealth ? null : _refreshHealth,
            icon: Icon(
              _healthStatus.isOnline
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: _healthStatus.isOnline
                  ? AppColors.emerald
                  : AppColors.amber,
            ),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        child: SafeArea(
          bottom: false,
          child: pageSwitcher,
        ),
      ),
      bottomNavigationBar: MobileGlassBottomNav(
        selectedIndex: _selectedIndex,
        onSelect: _selectTab,
      ),
    );
  }
}
