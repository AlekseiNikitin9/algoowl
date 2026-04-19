import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chapter_glyph.dart';
import '../../core/widgets/ck_chip.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/glass_bar.dart';
import '../../core/widgets/primary_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skill_tree_node.dart';
import '../../models/category.dart';
import '../../providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final s = _scrollCtrl.offset > 12;
      if (s != _scrolled) setState(() => _scrolled = s);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  static double offsetFor(int index, double max) {
    switch (index % 4) {
      case 0:
        return 0;
      case 1:
        return max;
      case 2:
        return 0;
      case 3:
        return -max;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final categories = ref.watch(categoriesProvider);
    final currentCat = categories.firstWhere(
      (c) => c.status == CategoryStatus.current,
      orElse: () => categories.first,
    );

    final rows = <_Row>[];
    for (final tier in kChapterTiers) {
      if (tier.startIndex >= categories.length) continue;
      final slice = categories.sublist(
        tier.startIndex,
        math.min(tier.endIndexExclusive, categories.length),
      );
      if (slice.isEmpty) continue;
      final unlocked = slice.any((c) => c.status != CategoryStatus.locked);
      rows.add(_ChapterRow(tier: tier, unlocked: unlocked));
      for (var i = 0; i < slice.length; i++) {
        rows.add(_NodeRow(category: slice[i], index: tier.startIndex + i));
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollCtrl,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 72,
              left: 16,
              right: 16,
              bottom: AppSpacing.bottomNavClearance + 40,
            ),
            children: [
              // Continue learning
              PrimaryCard(
                onTap: () => context.push('/unit/${currentCat.slug}'),
                child: _ContinueContent(
                  categoryName: currentCat.name,
                  progress: currentCat.progress,
                ),
              ),
              const SizedBox(height: 12),
              _TodaysReviewCard(onTap: () {}),
              const SizedBox(height: 28),
              const SectionHeader(label: 'Your path'),
              const SizedBox(height: 8),
              // Skill tree rows
              _buildSkillTree(rows),
            ],
          ),
          // Glass top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _scrolled
                  ? GlassBar(child: _topBarContent(user))
                  : Container(
                      key: const ValueKey('plain'),
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top,
                      ),
                      height: 56 + MediaQuery.paddingOf(context).top,
                      child: _topBarContent(user),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBarContent(user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          CkChip(
            leading: const CkIcon.flame(size: 16),
            label: '${user.streak}  day streak',
            background: AppColors.goldLight,
            foreground: AppColors.goldDark,
          ),
          const SizedBox(width: 8),
          CkChip(
            leading: const CkIcon.bolt(size: 14),
            label: '${user.xp} XP',
            background: AppColors.primarySurface,
            foreground: AppColors.primaryDark,
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(user.name),
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildSkillTree(List<_Row> rows) {
    final widgets = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row is _ChapterRow) {
        widgets.add(_ChapterRail(tier: row.tier, unlocked: row.unlocked));
      } else if (row is _NodeRow) {
        final prevNode = rows.sublist(0, i).reversed.whereType<_NodeRow>().firstOrNull;
        if (prevNode != null) {
          widgets.add(_Connector(
            fromIndex: prevNode.index,
            toIndex: row.index,
            isUnlocked: row.category.status != CategoryStatus.locked,
          ));
        } else {
          widgets.add(const SizedBox(height: 12));
        }
        widgets.add(
          Transform.translate(
            offset: Offset(offsetFor(row.index, 60), 0),
            child: Center(
              child: SkillTreeNode(
                category: row.category,
                onTap: () => context.push('/unit/${row.category.slug}'),
              ),
            ),
          ),
        );
      }
    }
    return Column(children: widgets);
  }
}

abstract class _Row {}

class _ChapterRow extends _Row {
  final ChapterTier tier;
  final bool unlocked;
  _ChapterRow({required this.tier, required this.unlocked});
}

class _NodeRow extends _Row {
  final Category category;
  final int index;
  _NodeRow({required this.category, required this.index});
}

class _ContinueContent extends StatelessWidget {
  final String categoryName;
  final double progress;
  const _ContinueContent({required this.categoryName, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CkIcon.play(size: 12, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'CONTINUE',
              style: AppTypography.eyebrow.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Two Sum',
          style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 2),
        Text(
          '$categoryName · Problem 2 of 5',
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: Colors.white.withValues(alpha: 0.22)),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0, 1),
                  child: Container(color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '${(progress * 100).round()}%',
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const Spacer(),
            Text(
              '+20 XP on finish',
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodaysReviewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _TodaysReviewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.15)),
            ),
            child: const Center(
              child: CkIcon.reset(size: 22, color: AppColors.goldDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Review", style: AppTypography.h3),
                const SizedBox(height: 2),
                Text(
                  '3 problems · ~8 min',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const CkIcon.chevR(size: 18, color: AppColors.textDisabled),
        ],
      ),
    );
  }
}

class _ChapterRail extends StatelessWidget {
  final ChapterTier tier;
  final bool unlocked;
  const _ChapterRail({required this.tier, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final opacity = unlocked ? 1.0 : 0.55;
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: unlocked ? AppColors.primarySurface : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: ChapterGlyph(
                kind: tier.glyph,
                size: 36,
                color: unlocked ? AppColors.primary : AppColors.textDisabled,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHAPTER ${kChapterTiers.indexOf(tier) + 1}',
                    style: AppTypography.eyebrow.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.name,
                    style: AppTypography.h2.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            Text(
              '${tier.endIndexExclusive - tier.startIndex} units',
              style: AppTypography.codeBody.copyWith(
                fontSize: 11,
                color: AppColors.textDisabled,
                letterSpacing: 0.08 * 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final int fromIndex;
  final int toIndex;
  final bool isUnlocked;

  const _Connector({
    required this.fromIndex,
    required this.toIndex,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConnectorPainter(
          fromX: _HomeScreenState.offsetFor(fromIndex, 60),
          toX: _HomeScreenState.offsetFor(toIndex, 60),
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
          dashed: !isUnlocked,
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final double fromX, toX;
  final Color color;
  final bool dashed;
  _ConnectorPainter({
    required this.fromX,
    required this.toX,
    required this.color,
    required this.dashed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final start = Offset(cx + fromX, 0);
    final end = Offset(cx + toX, size.height);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx, size.height * 0.4, end.dx, size.height * 0.6,
          end.dx, end.dy);
    if (!dashed) {
      canvas.drawPath(path, paint);
    } else {
      const dash = 5.0, gap = 4.0;
      for (final metric in path.computeMetrics()) {
        double d = 0;
        while (d < metric.length) {
          final e = math.min(d + dash, metric.length);
          canvas.drawPath(metric.extractPath(d, e), paint);
          d += dash + gap;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.fromX != fromX || old.toX != toX || old.color != color ||
      old.dashed != dashed;
}
