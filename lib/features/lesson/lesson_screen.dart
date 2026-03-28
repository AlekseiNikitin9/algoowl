import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/owl_button.dart';
import '../../core/widgets/progress_bar.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

/// A lesson flow: concept → quiz → input method choice → code editor.
class LessonScreen extends ConsumerStatefulWidget {
  final String problemSlug;

  const LessonScreen({super.key, required this.problemSlug});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  // Steps: 0=concept, 1=quiz, 2=input method, 3=go to editor
  int _step = 0;
  int? _selectedAnswer;
  bool _answered = false;
  String? _inputMethod; // 'manual' or 'autocompletion'

  late Problem _problem;

  @override
  void initState() {
    super.initState();
    final problems = ref.read(problemsProvider);
    _problem = problems.firstWhere(
      (p) => p.slug == widget.problemSlug,
      orElse: () => problems.first,
    );
  }

  // 4 steps total (0–3)
  double get _progress => (_step + 1) / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space2,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: OwlProgressBar(progress: _progress, height: 10),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: child,
                  );
                },
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildConceptCard();
      case 1:
        return _buildQuiz();
      case 2:
        return _buildInputMethodChoice();
      case 3:
        return _buildCodePrompt();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConceptCard() {
    return Padding(
      key: const ValueKey('concept'),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space6),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.auto_stories,
                  size: 64, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(_problem.title, style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space3),
          Text(
            _problem.description,
            style: AppTypography.bodyLg
                .copyWith(color: AppColors.textSecondary),
          ),
          if (_problem.constraints.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Constraints:\n${_problem.constraints}',
                style: AppTypography.caption
                    .copyWith(fontFamily: 'monospace'),
              ),
            ),
          ],
          const Spacer(),
          OwlButton(
            label: 'Continue',
            onPressed: () => setState(() => _step = 1),
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final options = [
      'O(n²) — nested loops',
      'O(n) — hash map lookup',
      'O(n log n) — sort first',
      'O(1) — math formula',
    ];
    const correctIndex = 1;

    return Padding(
      key: const ValueKey('quiz'),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space6),
          Text('Quick Check', style: AppTypography.h2),
          const SizedBox(height: AppSpacing.space2),
          Text(
            "What's the optimal time complexity for ${_problem.title}?",
            style: AppTypography.bodyLg,
          ),
          const SizedBox(height: AppSpacing.space6),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isSelected = _selectedAnswer == i;
            final showCorrect = _answered && i == correctIndex;
            final showWrong = _answered && isSelected && i != correctIndex;

            Color borderColor = AppColors.border;
            Color bgColor = AppColors.surface;
            if (showCorrect) {
              borderColor = AppColors.success;
              bgColor = AppColors.successLight;
            } else if (showWrong) {
              borderColor = AppColors.error;
              bgColor = AppColors.errorLight;
            } else if (isSelected && !_answered) {
              borderColor = AppColors.primary;
              bgColor = AppColors.primarySurface;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: GestureDetector(
                onTap: _answered
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedAnswer = i);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(opt, style: AppTypography.body)),
                      if (showCorrect)
                        const Icon(Icons.check_circle,
                            color: AppColors.success),
                      if (showWrong)
                        const Icon(Icons.cancel, color: AppColors.error),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          OwlButton(
            label: _answered ? 'Continue' : 'Check',
            onPressed: _selectedAnswer == null
                ? null
                : () {
                    if (_answered) {
                      setState(() => _step = 2);
                    } else {
                      HapticFeedback.mediumImpact();
                      setState(() => _answered = true);
                    }
                  },
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  // ── Input method choice (new step between quiz & editor) ─────
  Widget _buildInputMethodChoice() {
    final options = [
      (
        'manual',
        'Enter code manually',
        'Type your solution the way you would on a computer',
        Icons.keyboard_rounded,
      ),
      (
        'autocompletion',
        'Use smart autocompletion',
        'Build your solution step by step with guided suggestions',
        Icons.auto_fix_high_rounded,
      ),
    ];

    return Padding(
      key: const ValueKey('input-method'),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space6),
          Text('How would you like to\nsolve this?', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Choose how you want to enter your solution.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space8),
          ...options.map((opt) {
            final isSelected = _inputMethod == opt.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _inputMethod = opt.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySurface
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          opt.$4,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.$2, style: AppTypography.bodyLg),
                            const SizedBox(height: 2),
                            Text(opt.$3, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          OwlButton(
            label: 'Continue',
            onPressed: _inputMethod != null
                ? () => setState(() => _step = 3)
                : null,
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  Widget _buildCodePrompt() {
    final isAutocompletion = _inputMethod == 'autocompletion';
    return Padding(
      key: const ValueKey('code-prompt'),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAutocompletion ? Icons.auto_fix_high_rounded : Icons.code,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text('Time to code!', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space3),
          Text(
            isAutocompletion
                ? 'Smart autocompletion is ready. Build your solution with guided suggestions.'
                : 'Open the editor and solve "${_problem.title}".',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space10),
          OwlButton(
            label: 'Open Editor',
            onPressed: () => context.push('/editor/${_problem.slug}'),
          ),
        ],
      ),
    );
  }
}
