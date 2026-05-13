import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../app/controllers/app_theme_controller.dart';
import '../view_models/dashboard_view_model.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final themeController = Get.find<AppThemeController>();
    final dashboardController = Get.find<DashboardViewModel>();

    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: palette.sidebarBackground,
        border: Border(
          right: BorderSide(color: palette.sidebarBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrandSection(context),
          const SizedBox(height: 28),
          Obx(() {
            final currentSection = dashboardController.currentSection.value;
            return Column(
              children: [
                _buildNavigationButton(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  subtitle: 'Overview',
                  isSelected: currentSection == DashboardSection.dashboard,
                  onTap: () => dashboardController.selectSection(DashboardSection.dashboard),
                ),
                const SizedBox(height: 10),
                _buildNavigationButton(
                  context: context,
                  icon: Icons.campaign_rounded,
                  label: '\uACF5\uC9C0\uC0AC\uD56D',
                  subtitle: 'Notices',
                  isSelected: currentSection == DashboardSection.notices,
                  onTap: () => dashboardController.selectSection(DashboardSection.notices),
                ),
              ],
            );
          }),
          const Spacer(),
          Obx(() => _buildNavigationButton(
                context: context,
                icon: Icons.settings_rounded,
                label: 'Settings',
                subtitle: 'Preferences',
                isSelected: dashboardController.currentSection.value == DashboardSection.settings,
                onTap: () => dashboardController.selectSection(DashboardSection.settings),
              )),
          const SizedBox(height: 12),
          _buildThemeSettingCard(context, themeController),
          const SizedBox(height: 12),
          _buildManagerProfileCard(context),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [palette.accentBlue, palette.accentCyan],
            ),
            boxShadow: [
              BoxShadow(
                color: palette.glowColor,
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ParkFlow',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: palette.primaryText,
                    ),
              ),
              Text(
                'Integrated Control',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.mutedText,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return _NavigationButton(
      icon: icon,
      label: label,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildThemeSettingCard(BuildContext context, AppThemeController controller) {
    final palette = context.palette;

    return Obx(() {
      final isDarkMode = controller.isDarkMode;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? palette.selectedItemBackground : palette.panelBackground,
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 18,
                color: isDarkMode ? palette.accentCyan : palette.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDarkMode ? 'Enabled' : 'Disabled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.mutedText,
                        ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isDarkMode,
              onChanged: (_) => controller.toggleThemeMode(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildManagerProfileCard(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [palette.accentBlue, palette.accentCyan],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'K',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kim Admin',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Control Lead',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.mutedText,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? palette.selectedItemBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? palette.cardBorder : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? palette.accentCyan : palette.secondaryText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isSelected ? palette.primaryText : palette.secondaryText,
                          ),
                    ),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.mutedText,
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
