import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/category.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

// ── Data helpers ───────────────────────────────────────────────

class _PracticeItem {
  final String slug;
  final String title;
  final Difficulty difficulty;
  final String categoryName;
  final bool solved;
  final bool locked;

  const _PracticeItem({
    required this.slug,
    required this.title,
    required this.difficulty,
    required this.categoryName,
    this.solved = false,
    this.locked = false,
  });

  bool get available => !solved && !locked;
}

final _catNameBySlug = {for (final c in kCategories) c.slug: c.name};

List<_PracticeItem> _fromApi(
  List<Map<String, dynamic>> data,
  Set<String> solvedSlugs,
  Map<String, String> categoryStatuses,
) {
  return data.map((p) {
    final catSlug = p['category_slug'] as String? ?? '';
    final catStatus = categoryStatuses[catSlug] ?? 'current';
    return _PracticeItem(
      slug: p['slug'] as String,
      title: p['title'] as String,
      difficulty: _parseDiff(p['difficulty'] as String? ?? 'easy'),
      categoryName: _catNameBySlug[catSlug] ?? catSlug,
      solved: solvedSlugs.contains(p['slug'] as String),
      locked: catStatus == 'locked',
    );
  }).toList();
}

Difficulty _parseDiff(String s) {
  switch (s) {
    case 'medium': return Difficulty.medium;
    case 'hard': return Difficulty.hard;
    default: return Difficulty.easy;
  }
}

// ── Screen ─────────────────────────────────────────────────────

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String _filter = 'All';

  static const _filters = [
    'All',
    'Easy',
    'Medium',
    'Hard',
    'Available Unsolved',
    'Unavailable',
  ];

  bool _matchesFilter(_PracticeItem item) {
    switch (_filter) {
      case 'Easy':
        return item.difficulty == Difficulty.easy;
      case 'Medium':
        return item.difficulty == Difficulty.medium;
      case 'Hard':
        return item.difficulty == Difficulty.hard;
      case 'Available Unsolved':
        return item.available;
      case 'Unavailable':
        return item.locked;
      default:
        return true;
    }
  }

  static int _diffOrder(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 0;
      case Difficulty.medium:
        return 1;
      case Difficulty.hard:
        return 2;
    }
  }

  static void _sortByDifficulty(List<_PracticeItem> list) {
    list.sort(
      (a, b) => _diffOrder(a.difficulty).compareTo(_diffOrder(b.difficulty)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final problemsAsync = ref.watch(allProblemsProvider);
    final solvedAsync = ref.watch(solvedSlugsProvider);
    final categoryAsync = ref.watch(categoryStatusDataProvider);

    if (problemsAsync is AsyncLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (problemsAsync is AsyncError) {
      return Scaffold(
        body: Center(child: Text('Failed to load problems: ${problemsAsync.error}')),
      );
    }

    final problems = problemsAsync.valueOrNull ?? [];
    final solvedSlugs = solvedAsync.valueOrNull ?? {};
    final categoryStatuses = {
      for (final s in (categoryAsync.valueOrNull ?? []))
        s['slug'] as String: s['status'] as String
    };

    return _buildContent(context, _fromApi(problems, solvedSlugs, categoryStatuses));
  }

  Widget _buildContent(BuildContext context, List<_PracticeItem> all) {
    final filtered = all.where(_matchesFilter).toList();

    final solved = filtered.where((i) => i.solved).toList();
    final available = filtered.where((i) => i.available).toList();
    final locked = filtered.where((i) => i.locked).toList();

    _sortByDifficulty(solved);
    _sortByDifficulty(available);
    _sortByDifficulty(locked);

    // Stats from the full (unfiltered) list
    final allSolved = all.where((i) => i.solved).toList();
    final solvedEasy =
        allSolved.where((i) => i.difficulty == Difficulty.easy).length;
    final solvedMedium =
        allSolved.where((i) => i.difficulty == Difficulty.medium).length;
    final solvedHard =
        allSolved.where((i) => i.difficulty == Difficulty.hard).length;

    final colorScheme = Theme.of(context).colorScheme;

    // Build flat sliver items
    final List<Widget> cards = [];

    if (solved.isNotEmpty) {
      cards.add(_SectionHeader(
        label: 'Solved',
        count: solved.length,
        color: AppColors.success,
      ));
      for (final item in solved) {
        cards.add(_ProblemRow(
          item: item,
          onTap: () => context.push('/lesson/${item.slug}'),
        ));
      }
    }

    if (available.isNotEmpty) {
      cards.add(_SectionHeader(
        label: 'Available Unsolved',
        count: available.length,
        color: AppColors.primary,
      ));
      for (final item in available) {
        cards.add(_ProblemRow(
          item: item,
          onTap: () => context.push('/lesson/${item.slug}'),
        ));
      }
    }

    if (locked.isNotEmpty) {
      cards.add(_SectionHeader(
        label: 'Locked',
        count: locked.length,
        color: colorScheme.onSurfaceVariant,
        subtitle: 'Progress further to unlock',
      ));
      for (final item in locked) {
        cards.add(_ProblemRow(item: item, onTap: null));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
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
                      'Re-solve problems you\'ve completed, try what\'s unlocked, '
                      'or see what\'s ahead.',
                      style: AppTypography.body.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          value: '${allSolved.length}',
                          label: 'Solved',
                          color: colorScheme.onSurface,
                        ),
                      ),
                      _Divider(),
                      Expanded(
                        child: _StatCell(
                          value: '$solvedEasy',
                          label: 'Easy',
                          color: AppColors.success,
                        ),
                      ),
                      _Divider(),
                      Expanded(
                        child: _StatCell(
                          value: '$solvedMedium',
                          label: 'Medium',
                          color: AppColors.warning,
                        ),
                      ),
                      _Divider(),
                      Expanded(
                        child: _StatCell(
                          value: '$solvedHard',
                          label: 'Hard',
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  children: _filters
                      .expand((label) => [
                            _FilterChip(
                              label: label,
                              selected: _filter == label,
                              onTap: () =>
                                  setState(() => _filter = label),
                            ),
                            const SizedBox(width: 8),
                          ])
                      .toList()
                        ..removeLast(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),

            // Problem cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                    child: cards[index],
                  ),
                  childCount: cards.length,
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

// ── Sub-widgets ────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(context).colorScheme.outline,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final String? subtitle;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space2, bottom: AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  final _PracticeItem item;
  final VoidCallback? onTap;

  const _ProblemRow({required this.item, required this.onTap});

  Color _diffColor() {
    switch (item.difficulty) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.error;
    }
  }

  String _diffLabel() {
    switch (item.difficulty) {
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
    final isLocked = item.locked;
    final isSolved = item.solved;

    final dimColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    final diffColor = isLocked ? dimColor : _diffColor();

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            children: [
              // Difficulty dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: diffColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.bodyLg.copyWith(
                        color: isLocked
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _diffLabel(),
                          style: AppTypography.caption.copyWith(color: diffColor),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: AppTypography.caption.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.categoryName,
                          style: AppTypography.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              if (isLocked)
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                )
              else if (isSolved)
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AppColors.success,
                )
              else
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
