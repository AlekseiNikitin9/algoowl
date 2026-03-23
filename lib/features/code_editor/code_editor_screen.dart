import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/owl_button.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/xp_toast.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

/// The core code editor with smart autofill toolbar.
class CodeEditorScreen extends ConsumerStatefulWidget {
  final String problemSlug;

  const CodeEditorScreen({super.key, required this.problemSlug});

  @override
  ConsumerState<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends ConsumerState<CodeEditorScreen> {
  late Problem _problem;
  late List<_CodeLine> _lines;
  // ignore: unused_field — reserved for interactive slot navigation
  final int _activeSlotLine = -1;
  bool _submitted = false;
  bool _correct = false;

  @override
  void initState() {
    super.initState();
    final problems = ref.read(problemsProvider);
    _problem = problems.firstWhere(
      (p) => p.slug == widget.problemSlug,
      orElse: () => problems.first,
    );
    _initCodeLines();
  }

  void _initCodeLines() {
    // Parse starter code into lines with editable slots.
    final code =
        _problem.starterCode['python'] ?? 'def solve():\n    pass';
    _lines = code.split('\n').map((line) => _CodeLine(line)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────
            _buildTopBar(context),

            // ── Question ─────────────────────────
            _buildQuestion(),

            // ── Code canvas ──────────────────────
            Expanded(child: _buildCodeCanvas()),

            // ── Autofill toolbar ─────────────────
            if (!_submitted) _buildAutofillToolbar(),

            // ── Bottom actions ───────────────────
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: OwlProgressBar(progress: 0.5, height: 10),
          ),
          const SizedBox(width: AppSpacing.space3),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_problem.title, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.space2),
          Text(
            _problem.description,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCanvas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.codeBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.space4),
          itemCount: _lines.length,
          itemBuilder: (context, lineIndex) {
            return _buildCodeLine(lineIndex);
          },
        ),
      ),
    );
  }

  Widget _buildCodeLine(int lineIndex) {
    final line = _lines[lineIndex];
    final isHighlighted =
        lineIndex == _activeSlotLine;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.codeLineHl : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line number
          SizedBox(
            width: 32,
            child: Text(
              '${lineIndex + 1}',
              style: AppTypography.codeBody
                  .copyWith(color: AppColors.codeComment, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          // Code content with syntax highlighting
          Expanded(
            child: _buildHighlightedLine(line.text),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedLine(String text) {
    final spans = <TextSpan>[];
    final keywords = {
      'def', 'for', 'in', 'if', 'else', 'elif', 'return', 'while', 'class',
      'import', 'from', 'pass', 'break', 'continue', 'and', 'or', 'not',
      'True', 'False', 'None', 'range', 'len',
    };

    final words = text.split(RegExp(r'(\s+|(?=[():\[\],])|(?<=[():\[\],]))'));
    for (final word in words) {
      if (word.isEmpty) continue;

      // Slot markers [...]
      if (word.startsWith('[') && word.endsWith(']')) {
        spans.add(TextSpan(
          text: word,
          style: AppTypography.codeSlot,
        ));
      } else if (keywords.contains(word)) {
        spans.add(TextSpan(
          text: word,
          style: AppTypography.codeKeyword,
        ));
      } else if (word.startsWith('#')) {
        spans.add(TextSpan(
          text: word,
          style: AppTypography.codeBody
              .copyWith(color: AppColors.codeComment),
        ));
      } else if (RegExp(r'^\d+$').hasMatch(word)) {
        spans.add(TextSpan(
          text: word,
          style: AppTypography.codeBody
              .copyWith(color: AppColors.codeNumber),
        ));
      } else if (word.startsWith('"') || word.startsWith("'")) {
        spans.add(TextSpan(
          text: word,
          style: AppTypography.codeBody
              .copyWith(color: AppColors.codeString),
        ));
      } else {
        spans.add(TextSpan(
          text: word,
          style: AppTypography.codeBody,
        ));
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildAutofillToolbar() {
    final buttons = [
      ('for', 'for [i] in range([0], [n]):'),
      ('if', 'if [condition]:'),
      ('def', 'def [func]([args]):'),
      ('return', 'return [value]'),
      ('while', 'while [condition]:'),
      ('var', '[name] = [value]'),
      ('list', '[[]]'),
      ('print', 'print([value])'),
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        itemCount: buttons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, snippet) = buttons[index];
          return _AutofillButton(
            label: label,
            onTap: () {
              HapticFeedback.selectionClick();
              _insertSnippet(snippet);
            },
          );
        },
      ),
    );
  }

  void _insertSnippet(String snippet) {
    setState(() {
      // Find the comment line and replace it
      final commentIndex = _lines.indexWhere(
        (l) => l.text.contains('# your code here') || l.text.contains('// your code here'),
      );
      if (commentIndex >= 0) {
        final indent = '    ';
        _lines[commentIndex] = _CodeLine('$indent$snippet');
      } else {
        // Insert before last line
        final insertAt = _lines.length > 1 ? _lines.length - 1 : _lines.length;
        _lines.insert(insertAt, _CodeLine('    $snippet'));
      }
    });
  }

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _submitted ? null : () {
                // Get hint
                _showHintSheet(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: AppColors.borderStrong, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
              ),
              child: Text('Get Hint', style: AppTypography.label),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: OwlButton(
              label: _submitted ? 'Continue' : 'Check ✓',
              backgroundColor:
                  _submitted && _correct ? AppColors.success : null,
              shadowColor:
                  _submitted && _correct ? AppColors.successDark : null,
              onPressed: () {
                if (_submitted) {
                  context.pop();
                } else {
                  _submit(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    HapticFeedback.mediumImpact();
    setState(() {
      _submitted = true;
      _correct = true; // Mock: always correct for now
    });
    if (_correct) {
      ref.read(userProfileProvider.notifier).addXp(15);
      showXpToast(context, 15);
    }
  }

  void _showHintSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: AppColors.warning, size: 24),
                  const SizedBox(width: 8),
                  Text('AI Hint', style: AppTypography.h2),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Think about using a hash map to store values you\'ve already seen. '
                'For each element, check if target - current exists in the map.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.space6),
              OwlButton(
                label: 'Got it',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CodeLine {
  final String text;
  _CodeLine(this.text);
}

class _AutofillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AutofillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
