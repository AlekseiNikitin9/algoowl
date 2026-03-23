import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/owl_button.dart';
import '../../models/problem.dart';

/// Results screen after code submission.
class ResultsScreen extends StatefulWidget {
  final Problem problem;
  final bool correct;
  final int xpEarned;

  const ResultsScreen({
    super.key,
    required this.problem,
    required this.correct,
    this.xpEarned = 15,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _controller.forward();

    if (widget.correct) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.correct
          ? AppColors.successLight
          : AppColors.errorLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.space10),

              // Result icon
              AnimatedBuilder(
                animation: _iconScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.correct
                            ? AppColors.success
                            : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.correct ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.space6),

              Text(
                widget.correct ? 'Correct!' : 'Not quite...',
                style: AppTypography.h1.copyWith(
                  color: widget.correct
                      ? AppColors.successDark
                      : AppColors.errorDark,
                ),
              ),

              const SizedBox(height: AppSpacing.space8),

              // Test cases
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Test Cases', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.space3),
                      ...widget.problem.testCases.map((tc) {
                        final passed = widget.correct || !tc.isHidden;
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.space2),
                          child: Row(
                            children: [
                              Icon(
                                passed ? Icons.check_circle : Icons.cancel,
                                color: passed
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tc.isHidden
                                      ? 'Hidden test case'
                                      : '${tc.input} → ${tc.expectedOutput}',
                                  style: AppTypography.body.copyWith(
                                    color: tc.isHidden
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.space4),
                      // Runtime stats
                      Row(
                        children: [
                          _StatChip(label: 'Runtime', value: '12ms'),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Memory', value: '14MB'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      // AI feedback
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome,
                                    size: 16,
                                    color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('AI Feedback',
                                    style: AppTypography.label),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Good use of linear scan. Consider edge case: '
                              'empty input array.',
                              style: AppTypography.body,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.space4),

              OwlButton(
                label: 'Continue →',
                backgroundColor:
                    widget.correct ? AppColors.success : AppColors.primary,
                shadowColor:
                    widget.correct ? AppColors.successDark : AppColors.primaryDark,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTypography.caption,
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: AppTypography.label
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
