import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problems = ref.watch(problemsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.space6,
                  AppSpacing.screenPadding,
                  AppSpacing.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Practice', style: AppTypography.h1),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      'Free practice by topic and difficulty',
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  children: [
                    _FilterChip(label: 'All', selected: true),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Easy', selected: false),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Medium', selected: false),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Hard', selected: false),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Unsolved', selected: false),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space4),
            ),

            // Problem list
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final problem = problems[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: _ProblemCard(
                        problem: problem,
                        onTap: () =>
                            context.push('/lesson/${problem.slug}'),
                      ),
                    );
                  },
                  childCount: problems.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.bottomNavClearance),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: selected ? AppColors.primary : colorScheme.outline,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: selected ? Colors.white : colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final Problem problem;
  final VoidCallback onTap;

  const _ProblemCard({required this.problem, required this.onTap});

  Color get _difficultyColor {
    switch (problem.difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.error;
    }
  }

  String get _difficultyLabel {
    switch (problem.difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            // Difficulty dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _difficultyColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(problem.title, style: AppTypography.bodyLg),
                  const SizedBox(height: 2),
                  Text(
                    _difficultyLabel,
                    style: AppTypography.caption
                        .copyWith(color: _difficultyColor),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
