import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/skill_tree_node.dart';
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
                child: Row(
                  children: [
                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 4),
                          Text(
                            '${user.streak}',
                            style: AppTypography.label
                                .copyWith(color: AppColors.goldDark),
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
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${user.xp} XP',
                            style: AppTypography.label
                                .copyWith(color: AppColors.primaryDark),
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
                ),
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
                        Container(
                          width: 2,
                          height: 32,
                          color: category.status == CategoryStatus.locked
                              ? AppColors.border
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      SkillTreeNode(
                        category: category,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
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
                Text("Today's Review", style: AppTypography.h3),
                Text(
                  '$dueCount problems due',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.goldDark),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.goldDark,
          ),
        ],
      ),
    );
  }
}
