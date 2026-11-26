import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class NavDestinationItem {
  const NavDestinationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.subtitle,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String subtitle;
}

const List<NavDestinationItem> appNavItems = [
  NavDestinationItem(
    label: 'Dashboard',
    icon: Icons.space_dashboard_outlined,
    activeIcon: Icons.space_dashboard_rounded,
    subtitle: 'Overview & KPIs',
  ),
  NavDestinationItem(
    label: 'Predict Grade',
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome_rounded,
    subtitle: '10-Feature Input',
  ),
  NavDestinationItem(
    label: 'Model & API',
    icon: Icons.hub_outlined,
    activeIcon: Icons.hub_rounded,
    subtitle: 'Metrics & Server',
  ),
];

/// Animated sliding side navigation drawer for desktop / wide screens.
class DesktopSideNav extends StatelessWidget {
  const DesktopSideNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
    required this.healthStatus,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final ApiHealthStatus healthStatus;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.effectiveDuration(context, AppMotion.medium);
    final width = collapsed ? 88.0 : 264.0;

    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.standardCurve,
      width: width,
      margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.navyCard.withValues(alpha: 0.88),
                  AppColors.navySurface.withValues(alpha: 0.82),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.11),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: collapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      if (!collapsed)
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: AppColors.heroGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyan
                                          .withValues(alpha: 0.32),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GradePulse',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'ML Predictor',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.cyanBright,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        tooltip:
                            collapsed ? 'Expand sidebar' : 'Collapse sidebar',
                        onPressed: onToggleCollapse,
                        icon: AnimatedRotation(
                          turns: collapsed ? 0.5 : 0.0,
                          duration: duration,
                          curve: AppMotion.standardCurve,
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: appNavItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = appNavItems[index];
                      final selected = index == selectedIndex;
                      return _SideNavTile(
                        item: item,
                        selected: selected,
                        collapsed: collapsed,
                        onTap: () => onSelect(index),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: AnimatedContainer(
                    duration: duration,
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed ? 10 : 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: (healthStatus.isOnline
                              ? AppColors.emerald
                              : AppColors.amber)
                          .withValues(alpha: 0.12),
                      border: Border.all(
                        color: (healthStatus.isOnline
                                ? AppColors.emerald
                                : AppColors.amber)
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: collapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: healthStatus.isOnline
                                ? AppColors.emerald
                                : AppColors.amber,
                            boxShadow: [
                              BoxShadow(
                                color: (healthStatus.isOnline
                                        ? AppColors.emerald
                                        : AppColors.amber)
                                    .withValues(alpha: 0.7),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        if (!collapsed) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              healthStatus.message,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
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
}

class _SideNavTile extends StatefulWidget {
  const _SideNavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final NavDestinationItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SideNavTile> createState() => _SideNavTileState();
}

class _SideNavTileState extends State<_SideNavTile> {
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
          curve: AppMotion.standardCurve,
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 10 : 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.selected
                ? LinearGradient(
                    colors: [
                      AppColors.electricBlue.withValues(alpha: 0.28),
                      AppColors.cyan.withValues(alpha: 0.16),
                    ],
                  )
                : null,
            color: !widget.selected && _hovered
                ? Colors.white.withValues(alpha: 0.06)
                : null,
            border: Border.all(
              color: widget.selected
                  ? AppColors.cyanBright.withValues(alpha: 0.48)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: widget.collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: duration,
                width: 3.5,
                height: widget.selected ? 22 : 0,
                margin: EdgeInsets.only(right: widget.collapsed ? 0 : 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: AppColors.primaryGradient,
                ),
              ),
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  widget.selected ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey('${widget.item.label}-${widget.selected}'),
                  color: widget.selected
                      ? AppColors.cyanBright
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              if (!widget.collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              widget.selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                          color: widget.selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.item.subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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

/// Frosted glass mobile bottom navigation bar with animated active pill.
class MobileGlassBottomNav extends StatelessWidget {
  const MobileGlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.effectiveDuration(context, AppMotion.medium);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppColors.navyCard.withValues(alpha: 0.88),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(appNavItems.length, (index) {
                  final item = appNavItems[index];
                  final selected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(index),
                      child: AnimatedContainer(
                        duration: duration,
                        curve: AppMotion.standardCurve,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: selected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.electricBlue
                                        .withValues(alpha: 0.30),
                                    AppColors.cyan.withValues(alpha: 0.18),
                                  ],
                                )
                              : null,
                          border: Border.all(
                            color: selected
                                ? AppColors.cyanBright.withValues(alpha: 0.45)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: selected ? 1.12 : 1.0,
                              duration: duration,
                              curve: AppMotion.standardCurve,
                              child: Icon(
                                selected ? item.activeIcon : item.icon,
                                size: 21,
                                color: selected
                                    ? AppColors.cyanBright
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile slide-over glass drawer for quick access to pages and backend status.
class MobileGlassDrawer extends StatelessWidget {
  const MobileGlassDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.healthStatus,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final ApiHealthStatus healthStatus;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.navySurface.withValues(alpha: 0.96),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: AppColors.heroGradient,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GradePulse AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Student Performance ML',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cyanBright,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ...List.generate(appNavItems.length, (index) {
                final item = appNavItems[index];
                final selected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SideNavTile(
                    item: item,
                    selected: selected,
                    collapsed: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect(index);
                    },
                  ),
                );
              }),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      healthStatus.isOnline
                          ? Icons.check_circle_rounded
                          : Icons.cloud_off_rounded,
                      color: healthStatus.isOnline
                          ? AppColors.emerald
                          : AppColors.amber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        healthStatus.message,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
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
}
