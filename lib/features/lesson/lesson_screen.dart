import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chapter_glyph.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/owl_button.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

class _ChatMsg {
  final String role; // 'user' | 'ai'
  final String text;
  const _ChatMsg({required this.role, required this.text});
}

class LessonScreen extends ConsumerStatefulWidget {
  final String problemSlug;
  const LessonScreen({super.key, required this.problemSlug});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  static const _totalSteps = 5;

  int _step = 0;
  int? _selected;
  bool _answered = false;

  final _chat = <_ChatMsg>[];
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _aiTyping = false;
  int _aiResponses = 0;
  static const _maxAi = 3;

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

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  double get _progress => (_step + 1) / _totalSteps;
  bool get _chatDone => _aiResponses >= _maxAi;

  void _next() {
    setState(() {
      _step++;
      _selected = null;
      _answered = false;
    });
  }

  void _prev() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() {
        _step--;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _seedOpeningChat() {
    if (_chat.isNotEmpty) return;
    setState(() {
      _chat.add(_ChatMsg(
        role: 'ai',
        text:
            'Before we open the editor, let\'s think through "${_problem.title}" together. '
            'What\'s your first instinct — any data structure or approach come to mind?',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(progress: _progress, step: _step + 1, total: _totalSteps, onClose: _prev),
            Expanded(child: _buildStepBody()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    if (_step == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _seedOpeningChat());
      return _ChatStep(
        chat: _chat,
        typing: _aiTyping,
        done: _chatDone,
        scrollCtrl: _scrollCtrl,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuart)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: switch (_step) {
        0 => _ConceptStep(key: const ValueKey('concept'), problem: _problem),
        1 => _QuizStep(
            key: const ValueKey('approach'),
            quiz: _problem.lessonContent.approachQuiz,
            selected: _selected,
            answered: _answered,
            onPick: (i) {
              HapticFeedback.selectionClick();
              setState(() => _selected = i);
            },
          ),
        2 => _QuizStep(
            key: const ValueKey('complexity'),
            quiz: _problem.lessonContent.complexityQuiz,
            selected: _selected,
            answered: _answered,
            onPick: (i) {
              HapticFeedback.selectionClick();
              setState(() => _selected = i);
            },
          ),
        4 => _ReadyStep(key: const ValueKey('ready'), problem: _problem),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildBottomBar() {
    if (_step == 3) {
      return _ChatComposer(
        controller: _msgCtrl,
        disabled: _aiTyping,
        onSend: _sendMessage,
        done: _chatDone,
        onReady: _next,
      );
    }
    return _BottomActionBar(
      child: switch (_step) {
        0 => OwlButton(
            label: 'Continue',
            onPressed: _next,
            leading: null,
          ),
        1 || 2 => !_answered
            ? OwlButton(
                label: 'Check',
                onPressed: _selected == null
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        setState(() => _answered = true);
                      },
              )
            : OwlButton(
                label: 'Continue',
                variant: _isCurrentAnswerCorrect()
                    ? OwlButtonVariant.success
                    : OwlButtonVariant.primary,
                onPressed: _next,
              ),
        4 => OwlButton.success(
            label: 'Open Code Editor',
            onPressed: () => context.push('/editor/${_problem.slug}'),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  bool _isCurrentAnswerCorrect() {
    final quiz = _step == 1
        ? _problem.lessonContent.approachQuiz
        : _problem.lessonContent.complexityQuiz;
    if (quiz == null || _selected == null) return false;
    return _selected == quiz.correctIndex;
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _aiTyping) return;
    HapticFeedback.selectionClick();
    _msgCtrl.clear();
    setState(() {
      _chat.add(_ChatMsg(role: 'user', text: text));
      _aiTyping = true;
    });
    _scrollToBottom();

    final history = _chat
        .sublist(0, _chat.length - 1)
        .map((m) => {'role': m.role == 'ai' ? 'model' : m.role, 'text': m.text})
        .toList();
    final isFinal = _aiResponses == _maxAi - 1;
    final api = ref.read(apiServiceProvider);
    final result = await api.chatWithTutor(
      problemTitle: _problem.title,
      problemDescription: _problem.description,
      messages: history,
      newMessage: text,
      isFinalRound: isFinal,
    );
    final reply = result['reply'] as String? ??
        'Keep thinking — you\'re on the right track.';
    setState(() {
      _aiTyping = false;
      _chat.add(_ChatMsg(role: 'ai', text: reply));
      _aiResponses++;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// ── Top bar ─────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final double progress;
  final int step, total;
  final VoidCallback onClose;
  const _TopBar({
    required this.progress,
    required this.step,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: CkIcon.close(size: 18, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: scheme.outline),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Row(
                  children: [
                    Expanded(
                      flex: (progress * 1000).round(),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex: 1000 - (progress * 1000).round(), child: const SizedBox()),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$step/$total',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom action bar (no Spacer; always pinned) ────────────

class _BottomActionBar extends StatelessWidget {
  final Widget child;
  const _BottomActionBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0), bg],
          stops: const [0, 0.4],
        ),
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

// ── Step 0: Concept ─────────────────────────────────────────

class _ConceptStep extends ConsumerWidget {
  final Problem problem;
  const _ConceptStep({super.key, required this.problem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final cat = categories.firstWhere(
      (c) => c.id == problem.categoryId,
      orElse: () => categories.first,
    );
    final diffLabel = switch (problem.difficulty) {
      Difficulty.easy => 'Easy',
      Difficulty.medium => 'Medium',
      Difficulty.hard => 'Hard',
    };
    final example = problem.testCases.where((tc) => !tc.isHidden).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cat.name} · $diffLabel'.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            problem.title,
            style: AppTypography.display.copyWith(height: 1.05),
          ),
          const SizedBox(height: 10),
          Text(
            problem.description,
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          if (example != null) ...[
            const SizedBox(height: 20),
            _ExampleCard(example: example),
          ],
          const SizedBox(height: 20),
          _SectionRule(label: "What you'll learn"),
          const SizedBox(height: 14),
          _LearningItem(
            index: 1,
            title: 'Using a hash map for O(1) lookups',
            detail: 'The core pattern',
          ),
          const SizedBox(height: 8),
          _LearningItem(
            index: 2,
            title: 'Complement arithmetic: target − num',
            detail: 'Why one pass works',
          ),
          const SizedBox(height: 8),
          _LearningItem(
            index: 3,
            title: 'Trading space for time',
            detail: 'Classic memoization idea',
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final TestCase example;
  const _ExampleCard({required this.example});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXAMPLE',
            style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          _kvLine('input ', example.input, AppColors.textPrimary),
          const SizedBox(height: 2),
          _kvLine('output', example.expectedOutput, AppColors.successDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CkIcon.hint(size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'The indices are 0-based and every input has exactly one valid pair.',
                    style: AppTypography.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvLine(String label, String value, Color valColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: AppColors.textDisabled,
              height: 1.7,
            )),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: valColor,
                height: 1.7,
              )),
        ),
      ],
    );
  }
}

class _SectionRule extends StatelessWidget {
  final String label;
  const _SectionRule({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        const SizedBox(width: 12),
        Text(label.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}

class _LearningItem extends StatelessWidget {
  final int index;
  final String title, detail;
  const _LearningItem({required this.index, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLg.copyWith(fontSize: 14)),
                const SizedBox(height: 1),
                Text(detail,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz step ───────────────────────────────────────────────

class _QuizStep extends StatelessWidget {
  final LessonQuiz? quiz;
  final int? selected;
  final bool answered;
  final ValueChanged<int> onPick;

  const _QuizStep({
    super.key,
    required this.quiz,
    required this.selected,
    required this.answered,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    if (quiz == null) return const SizedBox.shrink();
    const letters = ['A', 'B', 'C', 'D'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHECK YOUR UNDERSTANDING',
            style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            quiz!.question,
            style: AppTypography.h2.copyWith(fontSize: 22, height: 1.25),
          ),
          const SizedBox(height: 18),
          ...quiz!.options.asMap().entries.map((e) {
            final i = e.key;
            final state = answered
                ? (i == quiz!.correctIndex
                    ? _OptState.correct
                    : selected == i
                        ? _OptState.wrong
                        : _OptState.idle)
                : (selected == i ? _OptState.selected : _OptState.idle);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _QuizOption(
                letter: letters[i],
                text: e.value,
                state: state,
                onTap: answered ? null : () => onPick(i),
              ),
            );
          }),
          if (answered && quiz!.explanation.isNotEmpty) ...[
            const SizedBox(height: 16),
            _QuizFeedback(
              correct: selected == quiz!.correctIndex,
              explanation: quiz!.explanation,
            ),
          ],
        ],
      ),
    );
  }
}

enum _OptState { idle, selected, correct, wrong }

class _QuizOption extends StatelessWidget {
  final String letter, text;
  final _OptState state;
  final VoidCallback? onTap;

  const _QuizOption({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg = scheme.surface;
    Color border = scheme.outline;
    Color letterBg = scheme.surfaceContainerHighest;
    Color letterFg = AppColors.textSecondary;
    Color letterBorder = AppColors.borderStrong;
    double borderWidth = 1;
    switch (state) {
      case _OptState.selected:
        border = AppColors.primary;
        bg = AppColors.primarySurface;
        borderWidth = 2;
        break;
      case _OptState.correct:
        border = AppColors.success;
        bg = AppColors.successLight;
        borderWidth = 2;
        letterBg = AppColors.success;
        letterFg = Colors.white;
        letterBorder = AppColors.success;
        break;
      case _OptState.wrong:
        border = AppColors.error;
        bg = AppColors.errorLight;
        borderWidth = 2;
        letterBg = AppColors.error;
        letterFg = Colors.white;
        letterBorder = AppColors.error;
        break;
      case _OptState.idle:
        break;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(borderWidth == 2 ? 13 : 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: border, width: borderWidth),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: letterBg,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: letterBorder),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: letterFg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body.copyWith(fontSize: 14, height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizFeedback extends StatelessWidget {
  final bool correct;
  final String explanation;
  const _QuizFeedback({required this.correct, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (correct ? AppColors.successDark : AppColors.errorDark)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? "Nice — that's it".toUpperCase() : 'NOT QUITE',
            style: AppTypography.eyebrow.copyWith(
              color: correct ? AppColors.successDark : AppColors.errorDark,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: AppTypography.body.copyWith(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Chat ────────────────────────────────────────────

class _ChatStep extends StatelessWidget {
  final List<_ChatMsg> chat;
  final bool typing, done;
  final ScrollController scrollCtrl;
  const _ChatStep({
    required this.chat,
    required this.typing,
    required this.done,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Text(
          'AI TUTOR',
          style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's think it through",
          style: AppTypography.h2.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        for (final m in chat)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Bubble(msg: m),
          ),
        if (typing)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _Bubble(msg: _ChatMsg(role: 'ai', text: ''), typing: true),
          ),
        if (done && !typing)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CkIcon.check(size: 14, color: AppColors.successDark),
                  const SizedBox(width: 6),
                  Text(
                    "You've got the approach",
                    style: AppTypography.label.copyWith(
                      color: AppColors.successDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMsg msg;
  final bool typing;
  const _Bubble({required this.msg, this.typing = false});

  @override
  Widget build(BuildContext context) {
    final isAi = msg.role == 'ai';
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isAi) ...[
          const _TutorAvatar(),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints:
                BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
            decoration: BoxDecoration(
              color: isAi ? scheme.surface : AppColors.primary,
              border: isAi ? Border.all(color: scheme.outline) : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isAi ? 4 : 16),
                bottomRight: Radius.circular(isAi ? 16 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A1F2E).withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: typing
                ? const _TypingDots()
                : Text(
                    msg.text,
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: isAi ? scheme.onSurface : Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _TutorAvatar extends StatelessWidget {
  const _TutorAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(16, 16),
          painter: _TutorMarkPainter(),
        ),
      ),
    );
  }
}

class _TutorMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(3, 8)
      ..lineTo(6, 5)
      ..lineTo(9, 8)
      ..lineTo(12, 5)
      ..lineTo(13, 6);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(const Offset(12, 10), 1.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final t = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
            final bounce = (t < 0.3) ? (t / 0.3) * -4 : 0.0;
            final opacity = 0.45 + (t < 0.3 ? (t / 0.3) * 0.55 : 0);
            return Positioned(
              left: i * 10.0,
              top: 4 + bounce,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textSecondary.withValues(alpha: opacity),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool disabled, done;
  final VoidCallback onSend, onReady;

  const _ChatComposer({
    required this.controller,
    required this.disabled,
    required this.done,
    required this.onSend,
    required this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (done) {
      return _BottomActionBar(
        child: OwlButton.success(
          label: "I'm ready — let's code",
          onPressed: onReady,
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) => TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 600,
                  enabled: !disabled,
                  style: AppTypography.body.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Share your thinking…',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: disabled ? null : onSend,
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final active =
                      controller.text.trim().isNotEmpty && !disabled;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? AppColors.primary : AppColors.surfaceAlt,
                    ),
                    alignment: Alignment.center,
                    child: CkIcon.send(
                      size: 16,
                      color: active ? Colors.white : AppColors.textDisabled,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 4: Ready ───────────────────────────────────────────

class _ReadyStep extends ConsumerWidget {
  final Problem problem;
  const _ReadyStep({super.key, required this.problem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final cat = categories.firstWhere(
      (c) => c.id == problem.categoryId,
      orElse: () => categories.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primarySurface, AppColors.surface],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: ChapterGlyph(
                kind: cat.glyph,
                size: 64,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'READY',
            style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Time to write the code',
            style: AppTypography.h1.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 280,
            child: Text(
              "Scan once, remember what you've seen in a hash map, return when you find a complement.",
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CkIcon.bolt(size: 18, color: AppColors.goldDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('+${problem.xp} XP on finish',
                          style: AppTypography.bodyLg.copyWith(fontSize: 14)),
                      const SizedBox(height: 1),
                      Text('Solve in one pass for a 10 XP bonus',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
