import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.space8),

              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(user.name, style: AppTypography.h1),
              Text(
                user.experienceLevel.toUpperCase(),
                style: AppTypography.caption,
              ),

              const SizedBox(height: AppSpacing.space8),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatTile(
                    label: 'XP',
                    value: '${user.xp}',
                    icon: Icons.bolt,
                    color: AppColors.gold,
                  ),
                  _StatTile(
                    label: 'Streak',
                    value: '${user.streak}',
                    icon: Icons.local_fire_department,
                    color: AppColors.error,
                  ),
                  _StatTile(
                    label: 'Daily Goal',
                    value: '${user.dailyGoalMinutes}m',
                    icon: Icons.timer,
                    color: AppColors.primary,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space8),

              // Settings section
              _SettingsSection(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    label: 'Account',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.flag_outlined,
                    label: 'Daily Goal',
                    trailing: '${user.dailyGoalMinutes} min',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space4),

              // Sign out
              TextButton(
                onPressed: () {},
                child: Text(
                  'Sign Out',
                  style: AppTypography.label
                      .copyWith(color: AppColors.error),
                ),
              ),

              const SizedBox(height: AppSpacing.bottomNavClearance),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(value, style: AppTypography.h2),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final List<Widget> children;

  const _SettingsSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(label, style: AppTypography.bodyLg),
            ),
            if (trailing != null)
              Text(trailing!, style: AppTypography.caption),
            const SizedBox(width: AppSpacing.space1),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textDisabled,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
