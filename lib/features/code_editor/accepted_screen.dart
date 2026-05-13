import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chapter_glyph.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/owl_button.dart';
import '../../models/category.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

/// "Accepted" screen — large success badge, count-up XP, stat grid, chapter progress.
class AcceptedScreen extends ConsumerStatefulWidget {
  final String problemSlug;
  final Map<String, String>? complexity;
  const AcceptedScreen({super.key, required this.problemSlug, this.complexity});

  @override
  ConsumerState<AcceptedScreen> createState() => _AcceptedScreenState();
}

class _AcceptedScreenState extends ConsumerState<AcceptedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _xpAnim;
  late final Problem _problem;
  late final Category _category;

  static const _xpReward = 20;
  static const _runtimeMs = 4;

  @override
  void initState() {
    super.initState();
    final problems = ref.read(problemsProvider);
    _problem = problems.firstWhere(
      (p) => p.slug == widget.problemSlug,
      orElse: () => problems.first,
    );
    final cats = ref.read(categoriesProvider);
    _category = cats.firstWhere(
      (c) => c.slug == _problem.categoryId,
      orElse: () => cats.first,
    );
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _xpAnim = CurvedAnimation(parent: _c, curve: Curves.easeOutQuart);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final streak = ref.watch(userProfileProvider).streak;
    final chapterProgress = 0.6;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: CkIcon.close(size: 18, color: textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _SuccessBadge(),
                    const SizedBox(height: 16),
                    Text(
                      'ACCEPTED',
                      style: AppTypography.eyebrow.copyWith(
                        color: AppColors.successDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_problem.title} · solved',
                      style: AppTypography.display.copyWith(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_problem.testCases.isEmpty ? 3 : _problem.testCases.length} of ${_problem.testCases.isEmpty ? 3 : _problem.testCases.length} tests passed · $_runtimeMs ms',
                      style: AppTypography.body.copyWith(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedBuilder(
                      animation: _xpAnim,
                      builder: (_, __) {
                        final xp = (_xpReward * _xpAnim.value).round();
                        return _StatGrid(
                          xp: xp,
                          streakDays: streak + 1,
                          userTime: widget.complexity?['time'],
                          userSpace: widget.complexity?['space'],
                          optimalTime: _problem.optimalTime,
                          optimalSpace: _problem.optimalSpace,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _ChapterProgressCard(
                      category: _category,
                      progress: chapterProgress,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16, 12, 16,
                MediaQuery.paddingOf(context).bottom + 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OwlButton.ghost(
                      label: 'Home',
                      onPressed: () => context.go('/'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OwlButton.success(
                      label: 'Next problem',
                      onPressed: () => context.go('/'),
                      leading: const CkIcon.chevR(size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.successDark.withValues(alpha: 0.32),
            offset: const Offset(0, 20),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.4],
                ),
              ),
            ),
          ),
          const Center(
            child: CkIcon.check(size: 56, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final int xp;
  final int streakDays;
  final String? userTime;
  final String? userSpace;
  final String optimalTime;
  final String optimalSpace;

  const _StatGrid({
    required this.xp,
    required this.streakDays,
    this.userTime,
    this.userSpace,
    required this.optimalTime,
    required this.optimalSpace,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: [
        _StatTile(label: 'XP earned', value: '+$xp', highlight: true),
        _StatTile(label: 'Streak', value: '$streakDays days'),
        _StatTile(
          label: 'Time',
          value: userTime ?? '…',
          sublabel: 'optimal $optimalTime',
          mono: true,
        ),
        _StatTile(
          label: 'Space',
          value: userSpace ?? '…',
          sublabel: 'optimal $optimalSpace',
          mono: true,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final bool highlight;
  final bool mono;

  const _StatTile({
    required this.label,
    required this.value,
    this.sublabel,
    this.highlight = false,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    final labelColor = highlight ? AppColors.primaryDark : textSecondary;
    final valueColor = highlight ? AppColors.primaryDark : textPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.14)
                : AppColors.primarySurface)
            : surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? AppColors.primaryDark.withValues(alpha: 0.2)
              : border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              color: labelColor,
              fontSize: 10,
              letterSpacing: 0.12 * 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: (mono ? AppTypography.codeBody : AppTypography.display).copyWith(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 1),
            Text(
              sublabel!,
              style: AppTypography.caption.copyWith(
                color: labelColor.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChapterProgressCard extends StatelessWidget {
  final Category category;
  final double progress;

  const _ChapterProgressCard({
    required this.category,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: ChapterGlyph(kind: category.glyph, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Junior · ${category.name}',
                  style: AppTypography.caption.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 6,
                    color: surfaceAlt,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LayoutBuilder(
                        builder: (_, c) => Container(
                          width: c.maxWidth * progress,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '3 / 5',
            style: AppTypography.codeBody.copyWith(
              color: textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
