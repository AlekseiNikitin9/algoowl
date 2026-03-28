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
                    onTap: () => _showComingSoon(context, 'Account'),
                  ),
                  _SettingsTile(
                    icon: Icons.flag_outlined,
                    label: 'Daily Goal',
                    trailing: '${user.dailyGoalMinutes} min',
                    onTap: () => _showDailyGoalDialog(context, ref, user.dailyGoalMinutes),
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    onTap: () => _showComingSoon(context, 'Dark mode'),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => _showComingSoon(context, 'Notifications'),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => _showAboutSheet(context),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.space4),

              // Sign out
              TextButton(
                onPressed: () => _confirmSignOut(context, ref),
                child: Text(
                  'Sign Out',
                  style: AppTypography.label.copyWith(color: AppColors.error),
                ),
              ),

              const SizedBox(height: AppSpacing.bottomNavClearance),
            ],
          ),
        ),
      ),
    );
  }

  // ── Daily goal dialog ───────────────────────────────────────
  void _showDailyGoalDialog(BuildContext context, WidgetRef ref, int current) {
    final controller = TextEditingController(text: current.toString());
    final presets = [5, 10, 20, 30];

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Daily Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many minutes per day?',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  // Preset chips
                  Wrap(
                    spacing: 8,
                    children: presets.map((mins) {
                      return ChoiceChip(
                        label: Text('$mins min'),
                        selected: controller.text == mins.toString(),
                        onSelected: (_) {
                          setDialogState(
                              () => controller.text = mins.toString());
                        },
                        selectedColor: AppColors.primarySurface,
                        side: BorderSide(
                          color: controller.text == mins.toString()
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Custom text field
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Custom (minutes)',
                      suffixText: 'min',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final val = int.tryParse(controller.text.trim());
                    if (val != null && val > 0 && val <= 180) {
                      ref.read(userProfileProvider.notifier).setDailyGoal(val);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── About sheet ─────────────────────────────────────────────
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6 + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.code,
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Text('Codekata', style: AppTypography.h2),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Master DSA and crush your coding interviews — one bite-sized lesson at a time.',
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Version 0.1.0 — Early Access',
                style: AppTypography.caption,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Coming soon snackbar ────────────────────────────────────
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Sign out confirm ────────────────────────────────────────
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Sign out of Codekata?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Reset onboarding → back to onboarding flow
              ref.read(onboardingCompleteProvider.notifier).state = false;
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────

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
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: AppSpacing.space3),
            Expanded(child: Text(label, style: AppTypography.bodyLg)),
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
