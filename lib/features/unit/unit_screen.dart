import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chapter_glyph.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/glass_bar.dart';
import '../../core/widgets/owl_button.dart';
import '../../core/widgets/primary_card.dart';
import '../../models/category.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

class _DiffStyle {
  final String label;
  final Color fg, bg, dot;
  const _DiffStyle(this.label, this.fg, this.bg, this.dot);
}

const _diffStyles = {
  Difficulty.easy: _DiffStyle('Easy', AppColors.successDark, AppColors.successLight, AppColors.success),
  Difficulty.medium: _DiffStyle('Medium', AppColors.goldDark, AppColors.goldLight, AppColors.gold),
  Difficulty.hard: _DiffStyle('Hard', AppColors.errorDark, AppColors.errorLight, AppColors.error),
};

enum _Filter { all, easy, medium, hard }

class UnitScreen extends ConsumerStatefulWidget {
  final String slug;
  const UnitScreen({super.key, required this.slug});

  @override
  ConsumerState<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends ConsumerState<UnitScreen> {
  final _scrollCtrl = ScrollController();
  bool _scrolled = false;
  _Filter _filter = _Filter.all;

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
    final categories = ref.watch(categoriesProvider);
    final category = categories.firstWhere(
      (c) => c.slug == widget.slug,
      orElse: () => categories[math.min(1, categories.length - 1)],
    );
    final locked = category.status == CategoryStatus.locked;
    final problemsAsync = ref.watch(unitProblemsProvider(widget.slug));
    final problems = problemsAsync.valueOrNull ?? kLockedSampleProblems;

    int solvedIn(Difficulty d) =>
        problems.where((p) => p.difficulty == d && p.solved).length;
    List<UnitProblem> byDiff(Difficulty d) =>
        problems.where((p) => p.difficulty == d).toList();

    const diffs = [Difficulty.easy, Difficulty.medium, Difficulty.hard];
    final allDone = diffs.every((d) => solvedIn(d) >= 2);

    final filtered = switch (_filter) {
      _Filter.all => problems,
      _Filter.easy => byDiff(Difficulty.easy),
      _Filter.medium => byDiff(Difficulty.medium),
      _Filter.hard => byDiff(Difficulty.hard),
    };

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollCtrl,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 60,
              left: 16,
              right: 16,
              bottom: 120,
            ),
            children: [
              _UnitHero(
                category: category,
                solvedEasy: solvedIn(Difficulty.easy),
                solvedMedium: solvedIn(Difficulty.medium),
                solvedHard: solvedIn(Difficulty.hard),
                allDone: allDone,
              ),
              const SizedBox(height: 20),
              _DifficultyFilters(
                active: _filter,
                counts: {
                  _Filter.all: problems.length,
                  _Filter.easy: byDiff(Difficulty.easy).length,
                  _Filter.medium: byDiff(Difficulty.medium).length,
                  _Filter.hard: byDiff(Difficulty.hard).length,
                },
                onChange: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: 14),
              if (_filter == _Filter.all)
                ..._buildGroupedList(diffs, byDiff, solvedIn, locked)
              else
                ...filtered.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ProblemRow(
                        problem: e.value,
                        index: e.key,
                        locked: locked,
                        onOpen: () => context.push('/lesson/${e.value.slug}'),
                      ),
                    )),
            ],
          ),
          // Glass header
          Positioned(
            top: 0, left: 0, right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _scrolled
                  ? GlassBar(
                      child: _header(context, category.name, showTitle: true),
                    )
                  : Container(
                      key: const ValueKey('plain'),
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top,
                      ),
                      child: _header(context, category.name),
                    ),
            ),
          ),
          // Sticky CTA
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _StickyCta(
              locked: locked,
              onTap: () {
                final next = problems.firstWhere(
                  (p) => !p.solved,
                  orElse: () => problems.first,
                );
                context.push('/lesson/${next.slug}');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String title, {bool showTitle = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(
        children: [
          _BackButton(onTap: () => context.pop()),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: showTitle ? 1 : 0,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList(
    List<Difficulty> diffs,
    List<UnitProblem> Function(Difficulty) byDiff,
    int Function(Difficulty) solvedIn,
    bool locked,
  ) {
    final out = <Widget>[];
    for (final d in diffs) {
      final list = byDiff(d);
      if (list.isEmpty) continue;
      final style = _diffStyles[d]!;
      out.add(Padding(
        padding: const EdgeInsets.only(top: 14),
        child: _DiffSectionHeader(
          dot: style.dot,
          label: '${style.label} · ${solvedIn(d)}/2',
        ),
      ));
      for (var i = 0; i < list.length; i++) {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ProblemRow(
            problem: list[i],
            index: i,
            locked: locked,
            onOpen: () => context.push('/lesson/${list[i].slug}'),
          ),
        ));
      }
    }
    return out;
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outline),
        ),
        child: Center(
          child: CkIcon.chevL(size: 18, color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _UnitHero extends StatefulWidget {
  final Category category;
  final int solvedEasy, solvedMedium, solvedHard;
  final bool allDone;
  const _UnitHero({
    required this.category,
    required this.solvedEasy,
    required this.solvedMedium,
    required this.solvedHard,
    required this.allDone,
  });

  @override
  State<_UnitHero> createState() => _UnitHeroState();
}

class _UnitHeroState extends State<_UnitHero> {
  @override
  Widget build(BuildContext context) {
    final locked = widget.category.status == CategoryStatus.locked;
    final statusLabel = switch (widget.category.status) {
      CategoryStatus.completed => 'Completed',
      CategoryStatus.current => 'In progress',
      CategoryStatus.locked => 'Locked',
    };

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNIT · ${statusLabel.toUpperCase()}',
          style: AppTypography.eyebrow.copyWith(
            color: (locked ? AppColors.textSecondary : Colors.white)
                .withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            ChapterGlyph(
              kind: widget.category.glyph,
              size: 36,
              color: locked ? AppColors.textSecondary : Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.category.name,
                style: AppTypography.display.copyWith(
                  color: locked ? AppColors.textPrimary : Colors.white,
                  fontSize: 28,
                  height: 1.05,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          locked
              ? 'Finish the previous unit to unlock.'
              : 'Solve 2 problems in each difficulty to complete this unit.',
          style: AppTypography.body.copyWith(
            color: (locked ? AppColors.textSecondary : Colors.white)
                .withValues(alpha: 0.85),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _TierTile(label: 'EASY', n: widget.solvedEasy, locked: locked)),
            const SizedBox(width: 8),
            Expanded(child: _TierTile(label: 'MEDIUM', n: widget.solvedMedium, locked: locked)),
            const SizedBox(width: 8),
            Expanded(child: _TierTile(label: 'HARD', n: widget.solvedHard, locked: locked)),
          ],
        ),
        if (widget.allDone) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CkIcon.check(size: 13, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Unit complete',
                  style: AppTypography.label.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    if (locked) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surfaceAlt, AppColors.border],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1F2E).withValues(alpha: 0.05),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: content,
      );
    }
    return PrimaryCard(padding: const EdgeInsets.all(20), child: content);
  }
}

class _TierTile extends StatelessWidget {
  final String label;
  final int n;
  final bool locked;
  const _TierTile({required this.label, required this.n, required this.locked});

  @override
  Widget build(BuildContext context) {
    final done = n >= 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: locked
            ? AppColors.surface
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: locked
              ? AppColors.border
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.eyebrow.copyWith(
              fontSize: 10,
              color: (locked ? AppColors.textSecondary : Colors.white)
                  .withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${math.min(n, 2)}',
                style: AppTypography.display.copyWith(
                  fontSize: 20,
                  color: locked ? AppColors.textPrimary : Colors.white,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '/ 2',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: (locked ? AppColors.textSecondary : Colors.white)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (done) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: CkIcon.check(
                    size: 13,
                    color: locked ? AppColors.success : Colors.white,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i < n
                          ? (locked ? AppColors.success : Colors.white)
                          : (locked
                              ? AppColors.border
                              : Colors.white.withValues(alpha: 0.25)),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                if (i == 0) const SizedBox(width: 3),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyFilters extends StatelessWidget {
  final _Filter active;
  final Map<_Filter, int> counts;
  final ValueChanged<_Filter> onChange;

  const _DifficultyFilters({
    required this.active,
    required this.counts,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            count: counts[_Filter.all] ?? 0,
            active: active == _Filter.all,
            onTap: () => onChange(_Filter.all),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Easy',
            dotColor: AppColors.success,
            count: counts[_Filter.easy] ?? 0,
            active: active == _Filter.easy,
            onTap: () => onChange(_Filter.easy),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Medium',
            dotColor: AppColors.gold,
            count: counts[_Filter.medium] ?? 0,
            active: active == _Filter.medium,
            onTap: () => onChange(_Filter.medium),
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Hard',
            dotColor: AppColors.error,
            count: counts[_Filter.hard] ?? 0,
            active: active == _Filter.hard,
            onTap: () => onChange(_Filter.hard),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: active ? AppColors.primary : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? Colors.white : dotColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: fg.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffSectionHeader extends StatelessWidget {
  final Color dot;
  final String label;
  const _DiffSectionHeader({required this.dot, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: AppColors.border)),
          const SizedBox(width: 12),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: AppColors.border)),
        ],
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  final UnitProblem problem;
  final int index;
  final bool locked;
  final VoidCallback onOpen;

  const _ProblemRow({
    required this.problem,
    required this.index,
    required this.locked,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final style = _diffStyles[problem.difficulty]!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillBg = isDark ? style.dot.withValues(alpha: 0.18) : style.bg;
    final pillFg = isDark ? style.dot : style.fg;
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: InkWell(
        onTap: locked ? null : onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: problem.solved
                      ? AppColors.success
                      : isDark
                          ? Theme.of(context).colorScheme.surfaceContainerHighest
                          : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: problem.solved
                      ? null
                      : Border.all(color: Theme.of(context).colorScheme.outline),
                  boxShadow: problem.solved
                      ? [
                          BoxShadow(
                            color: AppColors.successDark.withValues(alpha: 0.25),
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: problem.solved
                    ? const CkIcon.check(size: 16, color: Colors.white)
                    : locked
                        ? const CkIcon.lock(size: 14, color: AppColors.textDisabled)
                        : Text(
                            '${index + 1}'.padLeft(2, '0'),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      problem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            style.label,
                            style: AppTypography.label.copyWith(
                              fontSize: 11,
                              color: pillFg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '+${problem.xp} XP · ${problem.minutes}m',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const CkIcon.chevR(size: 16, color: AppColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  final bool locked;
  final VoidCallback onTap;
  const _StickyCta({required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0), bg],
          stops: const [0, 0.4],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OwlButton(
          label: locked ? 'Locked' : 'Continue unit',
          onPressed: locked ? null : onTap,
          leading: locked
              ? const CkIcon.lock(size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

