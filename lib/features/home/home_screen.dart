import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/skill_tree_node.dart';
import 'dart:math' as math;

import '../../models/category.dart';
import '../../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top Bar: streak, XP, avatar ──────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.space3,
                  AppSpacing.screenPadding,
                  0,
                ),
                child: Builder(builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Row(
                  children: [
                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.goldLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 4),
                          Text(
                            '${user.streak}',
                            style: AppTypography.label.copyWith(
                              color: isDark
                                  ? AppColors.gold
                                  : AppColors.goldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    // XP
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${user.xp} XP',
                            style: AppTypography.label.copyWith(
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),

            // ── Continue Learning CTA ────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: _ContinueLearningCard(
                  categoryName: _currentCategory(categories)?.name ??
                      'Arrays & Strings',
                  progress:
                      _currentCategory(categories)?.progress ?? 0.4,
                  onTap: () => context.push('/lesson/two-sum'),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),

            // ── Today's Review ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: _ReviewCard(dueCount: 3),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space8),
            ),

            // ── "Your Path" header ───────────────────────
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  '── Your Path ──',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textDisabled),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space6),
            ),

            // ── Skill Tree ──────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = categories[index];
                  return Column(
                    children: [
                      if (index > 0)
                        _ZigzagConnector(
                          fromIndex: index - 1,
                          toIndex: index,
                          isUnlocked: category.status != CategoryStatus.locked,
                        ),
                      SkillTreeNode(
                        category: category,
                        index: index,
                        onTap: () =>
                            context.push('/practice/${category.slug}'),
                      ),
                    ],
                  );
                },
                childCount: categories.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.bottomNavClearance + 24),
            ),
          ],
        ),
      ),
    );
  }

  Category? _currentCategory(List<Category> categories) {
    return categories
        .where((c) => c.status == CategoryStatus.current)
        .firstOrNull;
  }
}

// ── Zigzag connector between nodes ───────────────────────────
/// Draws a curved line from the bottom-center of node [fromIndex] to the
/// top-center of node [toIndex], following their zigzag horizontal offsets.
class _ZigzagConnector extends StatelessWidget {
  final int fromIndex;
  final int toIndex;
  final bool isUnlocked;

  const _ZigzagConnector({
    required this.fromIndex,
    required this.toIndex,
    required this.isUnlocked,
  });

  static double _offsetFor(int index, double maxOffset) {
    switch (index % 4) {
      case 0:
        return 0;
      case 1:
        return maxOffset;
      case 2:
        return 0;
      case 3:
        return -maxOffset;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxOffset = screenWidth * 0.22;
    final fromX = _offsetFor(fromIndex, maxOffset);
    final toX = _offsetFor(toIndex, maxOffset);

    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: _CurvedLinePainter(
          fromX: fromX,
          toX: toX,
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
        ),
        size: Size(screenWidth, 40),
      ),
    );
  }
}

class _CurvedLinePainter extends CustomPainter {
  final double fromX;
  final double toX;
  final Color color;

  _CurvedLinePainter({
    required this.fromX,
    required this.toX,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final start = Offset(centerX + fromX, 0);
    final end = Offset(centerX + toX, size.height);

    // Cubic bezier for a smooth curve
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx,
        size.height * 0.4,
        end.dx,
        size.height * 0.6,
        end.dx,
        end.dy,
      );

    // Dashed line for locked nodes
    if (color == AppColors.border) {
      _drawDashed(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_CurvedLinePainter old) =>
      old.fromX != fromX || old.toX != toX || old.color != color;
}

// ── Continue Learning Card ────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  final String categoryName;
  final double progress;
  final VoidCallback onTap;

  const _ContinueLearningCard({
    required this.categoryName,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Continue Learning',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              categoryName,
              style:
                  AppTypography.bodyLg.copyWith(color: AppColors.primaryLight),
            ),
            const SizedBox(height: AppSpacing.space3),
            OwlProgressBar(
              progress: progress,
              height: 12,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).round()}%',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Review Card ──────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final int dueCount;

  const _ReviewCard({required this.dueCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldAccent = isDark ? AppColors.gold : AppColors.goldDark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.gold.withValues(alpha: 0.12)
            : AppColors.goldLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.replay, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Review",
                  style: AppTypography.h3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$dueCount problems due',
                  style: AppTypography.caption.copyWith(color: goldAccent),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: goldAccent),
        ],
      ),
    );
  }
}
