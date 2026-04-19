import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/ck_icons.dart';
import '../../providers/app_providers.dart';

/// Redesigned profile — glass scroll header, identity block, level card,
/// 3 stat cards, weekly activity chart, achievements grid, settings rows.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _scrollCtrl = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final s = _scrollCtrl.offset > 40;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: Stack(
        children: [
          ListView(
            controller: _scrollCtrl,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 64,
              left: 16,
              right: 16,
              bottom: AppSpacing.bottomNavClearance + 32,
            ),
            children: [
              _IdentityBlock(name: user.name),
              const SizedBox(height: 20),
              _LevelCard(xp: user.xp),
              const SizedBox(height: 14),
              _StatsRow(
                streak: user.streak,
                xp: user.xp,
                solved: 12,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'This week'),
              const SizedBox(height: 10),
              const _WeeklyChartCard(),
              const SizedBox(height: 20),
              _SectionLabel(
                label: 'Achievements',
                trailing: '3 of 6',
              ),
              const SizedBox(height: 10),
              const _AchievementsGrid(),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Settings'),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _SettingsRow(
                    label: 'Daily goal',
                    trailing: '${user.dailyGoalMinutes} min',
                    onTap: () => _showDailyGoalDialog(
                      context, ref, user.dailyGoalMinutes,
                    ),
                  ),
                  _SettingsRow(
                    label: 'Appearance',
                    trailing: _themeModeLabel(ref.watch(themeModeProvider)),
                    onTap: () => _showThemeDialog(context, ref),
                  ),
                  _SettingsRow(
                    label: 'Notifications',
                    trailing: 'On',
                    onTap: () => _showComingSoon(context, 'Notifications'),
                  ),
                  _SettingsRow(
                    label: 'Account',
                    onTap: () => _showComingSoon(context, 'Account'),
                  ),
                  _SettingsRow(
                    label: 'Help & feedback',
                    onTap: () => _showAboutSheet(context),
                    last: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () => _confirmSignOut(context, ref),
                  child: Text(
                    'Sign out',
                    style: AppTypography.label.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Codekata · v0.1.0',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          _TopGlassBar(scrolled: _scrolled, name: user.name),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // ── Theme dialog ───────────────────────────────────────────
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Appearance'),
          children: [
            for (final entry in const [
              (ThemeMode.light, 'Light'),
              (ThemeMode.dark, 'Dark'),
              (ThemeMode.system, 'System'),
            ])
              SimpleDialogOption(
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state = entry.$1;
                  Navigator.pop(ctx);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(entry.$2, style: AppTypography.bodyLg),
                    ),
                    if (current == entry.$1)
                      const CkIcon.check(
                          size: 20, color: AppColors.primary),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Daily goal dialog ──────────────────────────────────────
  void _showDailyGoalDialog(BuildContext context, WidgetRef ref, int current) {
    final controller = TextEditingController(text: current.toString());
    const presets = [5, 10, 20, 30];

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Daily goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many minutes per day?',
                    style: AppTypography.body.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: presets.map((mins) {
                      return ChoiceChip(
                        label: Text('$mins min'),
                        selected: controller.text == mins.toString(),
                        onSelected: (_) => setDialogState(
                          () => controller.text = mins.toString(),
                        ),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
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
                      ref
                          .read(userProfileProvider.notifier)
                          .setDailyGoal(val);
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

  // ── About bottom sheet ──────────────────────────────────────
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewPadding.bottom;
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.space6, AppSpacing.space6, AppSpacing.space6,
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
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const CkIcon.hint(
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Text('Codekata', style: AppTypography.h2),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Master DSA and crush your coding interviews — one bite-sized lesson at a time.',
                style: AppTypography.body.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Version 0.1.0 · Early access',
                style: AppTypography.caption.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Sign out of Codekata?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(onboardingCompleteProvider.notifier).state = false;
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

// ── Top glass bar ───────────────────────────────────────────────

class _TopGlassBar extends StatelessWidget {
  final bool scrolled;
  final String name;
  const _TopGlassBar({required this.scrolled, required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? AppColors.darkBg.withValues(alpha: scrolled ? 0.78 : 0.1)
        : AppColors.bg.withValues(alpha: scrolled ? 0.78 : 0.1);
    final border = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.35)
        : AppColors.borderStrong.withValues(alpha: 0.35);
    final top = MediaQuery.paddingOf(context).top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: scrolled ? 18 : 0,
          sigmaY: scrolled ? 18 : 0,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: top + 56,
          padding: EdgeInsets.only(top: top, left: 16, right: 16),
          decoration: BoxDecoration(
            color: tint,
            border: scrolled
                ? Border(bottom: BorderSide(color: border, width: 0.5))
                : null,
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedOpacity(
            opacity: scrolled ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Row(
              children: [
                _Avatar(name: name, size: 32, radius: 10),
                const SizedBox(width: 10),
                Text(name, style: AppTypography.h3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Identity block ──────────────────────────────────────────────

class _IdentityBlock extends StatelessWidget {
  final String name;
  const _IdentityBlock({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        _Avatar(name: name, size: 84, radius: 24),
        const SizedBox(height: 12),
        Text(
          name,
          style: AppTypography.display.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'Joined March 2026 · Junior dev',
          style: AppTypography.caption.copyWith(
            color: secondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  final double radius;

  const _Avatar({
    required this.name,
    required this.size,
    required this.radius,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            offset: Offset(0, size * 0.14),
            blurRadius: size * 0.5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
          color: Colors.white,
          letterSpacing: -0.015 * size * 0.42,
        ),
      ),
    );
  }
}

// ── Level card ──────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final int xp;
  const _LevelCard({required this.xp});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceAlt =
        isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    const xpPerLevel = 1000;
    final level = (xp ~/ xpPerLevel) + 1;
    final inLevel = xp % xpPerLevel;
    final progress = inLevel / xpPerLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'LEVEL $level',
                style: AppTypography.eyebrow.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              Text(
                '$inLevel / $xpPerLevel XP',
                style: AppTypography.codeBody.copyWith(
                  color: secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Junior · Hashing',
            style: AppTypography.display.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: surfaceAlt,
              child: LayoutBuilder(
                builder: (_, c) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: c.maxWidth * progress.clamp(0.0, 1.0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${xpPerLevel - inLevel} XP to Level ${level + 1}',
            style: AppTypography.caption.copyWith(
              color: secondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int streak;
  final int xp;
  final int solved;

  const _StatsRow({
    required this.streak,
    required this.xp,
    required this.solved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: const CkIcon.flame(size: 20, color: AppColors.gold),
            tint: AppColors.gold,
            value: '$streak',
            label: 'Streak',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: const CkIcon.bolt(size: 20, color: AppColors.primary),
            tint: AppColors.primary,
            value: '$xp',
            label: 'Total XP',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: const CkIcon.check(size: 20, color: AppColors.success),
            tint: AppColors.success,
            value: '$solved',
            label: 'Solved',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Widget icon;
  final Color tint;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.tint,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.display.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: secondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? trailing;
  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.h3.copyWith(color: primary, fontSize: 16),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: AppTypography.caption.copyWith(
                color: secondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Weekly chart ───────────────────────────────────────────────

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // Values 0..1; today is index 3 (Thursday).
  static const _values = [0.6, 0.8, 0.4, 0.9, 0.0, 0.0, 0.0];
  static const _todayIndex = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '42 min',
                style: AppTypography.display.copyWith(fontSize: 24),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'this week',
                  style: AppTypography.caption.copyWith(
                    color: secondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _days.length; i++)
                  Expanded(
                    child: _Bar(
                      value: _values[i],
                      isToday: i == _todayIndex,
                      isRest: _values[i] == 0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _days.length; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      _days[i],
                      style: AppTypography.caption.copyWith(
                        color: i == _todayIndex
                            ? AppColors.primary
                            : secondary,
                        fontSize: 11,
                        fontWeight: i == _todayIndex
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final bool isToday;
  final bool isRest;

  const _Bar({
    required this.value,
    required this.isToday,
    required this.isRest,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceAlt =
        isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt;
    final dashColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: LayoutBuilder(
        builder: (_, c) {
          final height = (c.maxHeight * value).clamp(4.0, c.maxHeight);
          if (isRest) {
            return CustomPaint(
              painter: _DashedBarPainter(color: dashColor),
              child: SizedBox(height: c.maxHeight, width: c.maxWidth),
            );
          }
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: isToday
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      )
                    : null,
                color: isToday ? null : surfaceAlt,
                border: isToday
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashedBarPainter extends CustomPainter {
  final Color color;
  _DashedBarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 4.0;
    const gap = 4.0;
    final x = size.width / 2;
    double y = size.height;
    while (y > 0) {
      final next = (y - dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(x, y), Offset(x, next), paint);
      y = next - gap;
    }
  }

  @override
  bool shouldRepaint(_DashedBarPainter old) => old.color != color;
}

// ── Achievements grid ─────────────────────────────────────────

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid();

  static const _items = <_Achievement>[
    _Achievement(label: 'First solve', glyph: _GlyphKind.bolt, unlocked: true),
    _Achievement(label: '7-day streak', glyph: _GlyphKind.flame, unlocked: true),
    _Achievement(label: 'Clean code', glyph: _GlyphKind.check, unlocked: true),
    _Achievement(label: '30-day streak', glyph: _GlyphKind.flame, unlocked: false),
    _Achievement(label: 'Hash master', glyph: _GlyphKind.bolt, unlocked: false),
    _Achievement(label: 'Graph guru', glyph: _GlyphKind.trophy, unlocked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: [for (final a in _items) _AchievementTile(data: a)],
    );
  }
}

enum _GlyphKind { bolt, flame, check, trophy }

class _Achievement {
  final String label;
  final _GlyphKind glyph;
  final bool unlocked;
  const _Achievement({
    required this.label,
    required this.glyph,
    required this.unlocked,
  });
}

class _AchievementTile extends StatelessWidget {
  final _Achievement data;
  const _AchievementTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final tint = switch (data.glyph) {
      _GlyphKind.bolt => AppColors.primary,
      _GlyphKind.flame => AppColors.gold,
      _GlyphKind.check => AppColors.success,
      _GlyphKind.trophy => AppColors.primaryDark,
    };

    final iconWidget = switch (data.glyph) {
      _GlyphKind.bolt => CkIcon.bolt(size: 24, color: tint),
      _GlyphKind.flame => CkIcon.flame(size: 24, color: tint),
      _GlyphKind.check => CkIcon.check(size: 24, color: tint),
      _GlyphKind.trophy => CkIcon.trophy(size: 24, color: tint),
    };

    return Opacity(
      opacity: data.unlocked ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.unlocked
                    ? tint.withValues(alpha: isDark ? 0.18 : 0.12)
                    : (isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.surfaceAlt),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: data.unlocked
                  ? iconWidget
                  : CkIcon.lock(size: 20, color: secondary),
            ),
            const SizedBox(height: 8),
            Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: data.unlocked
                    ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary)
                    : secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings card ─────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool last;

  const _SettingsRow({
    required this.label,
    this.trailing,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final secondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final primary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: last ? const Radius.circular(AppRadius.xl) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: border, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(
                  color: primary,
                  fontSize: 15,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  trailing!,
                  style: AppTypography.caption.copyWith(
                    color: secondary,
                    fontSize: 13,
                  ),
                ),
              ),
            CkIcon.chevR(size: 16, color: secondary),
          ],
        ),
      ),
    );
  }
}
