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

// ═══════════════════════════════════════════════════════════════
// Data
// ═══════════════════════════════════════════════════════════════

class _ChatMsg {
  final String role; // 'user' or 'ai'
  final String text;
  const _ChatMsg({required this.role, required this.text});
}

// ═══════════════════════════════════════════════════════════════
// Lesson flow: concept → approach quiz → complexity quiz →
//              AI tutor chat → time to code
// ═══════════════════════════════════════════════════════════════

class LessonScreen extends ConsumerStatefulWidget {
  final String problemSlug;
  const LessonScreen({super.key, required this.problemSlug});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  static const _totalSteps = 5;

  // 0 = concept, 1 = approach quiz, 2 = complexity quiz,
  // 3 = AI tutor chat, 4 = time to code
  int _step = 0;

  // Quiz state (shared between step 1 and 2)
  int? _selectedAnswer;
  bool _answered = false;

  // Chat state (step 3)
  final List<_ChatMsg> _chatMessages = [];
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _aiTyping = false;
  int _aiResponseCount = 0;
  static const _maxAiResponses = 3;

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
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double get _progress => (_step + 1) / _totalSteps;
  bool get _chatDone => _aiResponseCount >= _maxAiResponses;

  void _nextStep() {
    setState(() {
      _step++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  // When entering the chat step, seed the AI's opening question
  void _initChat() {
    if (_chatMessages.isNotEmpty) return;
    setState(() {
      _chatMessages.add(_ChatMsg(
        role: 'ai',
        text: 'Before we open the editor, let\'s think through "${_problem.title}" together! '
            'What\'s your first instinct for solving this? '
            'Any data structure or approach come to mind?',
      ));
    });
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                    child: Icon(Icons.close,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _step == 3
                  ? _buildChatStep() // no animation - chat persists
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutQuart,
                        )),
                        child: child,
                      ),
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
        return _buildApproachQuiz();
      case 2:
        return _buildComplexityQuiz();
      case 4:
        return _buildCodePrompt();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0: Concept card ──────────────────────────────────────

  Widget _buildConceptCard() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleCases =
        _problem.testCases.where((tc) => !tc.isHidden).toList();

    return SingleChildScrollView(
      key: const ValueKey('concept'),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space4),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.auto_stories,
                  size: 52, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          _DifficultyBadge(difficulty: _problem.difficulty),
          const SizedBox(height: AppSpacing.space3),
          Text(_problem.title, style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space3),
          Text(
            _problem.description,
            style:
                AppTypography.bodyLg.copyWith(color: cs.onSurfaceVariant),
          ),
          if (_problem.constraints.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Constraints',
                      style: AppTypography.caption
                          .copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(_problem.constraints,
                      style:
                          AppTypography.codeBody.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
          if (visibleCases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space6),
            Text('Examples', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.space3),
            ...visibleCases.asMap().entries.map((e) {
              final tc = e.value;
              final n = e.key + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example $n', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.space2),
                    _ExampleBlock(label: 'Input', content: tc.input),
                    const SizedBox(height: AppSpacing.space2),
                    _ExampleBlock(
                        label: 'Output', content: tc.expectedOutput),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.space6),
          OwlButton(
            label: 'Got it - let\'s learn',
            onPressed: _nextStep,
          ),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
    );
  }

  // ── Step 1: Approach quiz ─────────────────────────────────────

  Widget _buildApproachQuiz() {
    final quiz = _problem.lessonContent.approachQuiz;
    if (quiz == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _nextStep());
      return const SizedBox.shrink();
    }
    return _buildQuizStep(
      key: const ValueKey('approach-quiz'),
      label: 'Key Insight',
      question: quiz.question,
      options: quiz.options,
      correctIndex: quiz.correctIndex,
      explanation: quiz.explanation,
    );
  }

  // ── Step 2: Complexity quiz ───────────────────────────────────

  Widget _buildComplexityQuiz() {
    final quiz = _problem.lessonContent.complexityQuiz ??
        LessonQuiz(
          question:
              'What\'s the optimal time complexity for ${_problem.title}?',
          options: [
            'O(n\u00b2) - nested loops',
            'O(n log n) - sort first',
            'O(n) - linear scan',
            'O(1) - constant time',
          ],
          correctIndex: 2,
          explanation:
              'Most array problems can be solved in O(n) with the right data structure.',
        );

    return _buildQuizStep(
      key: const ValueKey('complexity-quiz'),
      label: 'Time Complexity',
      question: quiz.question,
      options: quiz.options,
      correctIndex: quiz.correctIndex,
      explanation: quiz.explanation,
    );
  }

  // ── Shared quiz widget ────────────────────────────────────────

  Widget _buildQuizStep({
    required ValueKey key,
    required String label,
    required String question,
    required List<String> options,
    required int correctIndex,
    String explanation = '',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      key: key,
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.primary)),
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(question, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.space6),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isSelected = _selectedAnswer == i;
            final showCorrect = _answered && i == correctIndex;
            final showWrong =
                _answered && isSelected && i != correctIndex;
            final cs = Theme.of(context).colorScheme;

            Color borderColor = cs.outline;
            Color bgColor = cs.surface;
            if (showCorrect) {
              borderColor = AppColors.success;
              bgColor = isDark
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.successLight;
            } else if (showWrong) {
              borderColor = AppColors.error;
              bgColor = isDark
                  ? AppColors.error.withValues(alpha: 0.15)
                  : AppColors.errorLight;
            } else if (isSelected && !_answered) {
              borderColor = AppColors.primary;
              bgColor = isDark
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primarySurface;
            }

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.space3),
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
                      Expanded(
                          child: Text(opt, style: AppTypography.body)),
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
          if (_answered && explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space3),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(explanation,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.success)),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          OwlButton(
            label: _answered ? 'Continue' : 'Check',
            onPressed: _selectedAnswer == null
                ? null
                : () {
                    if (_answered) {
                      _nextStep();
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

  // ── Step 3: AI Tutor Chat ─────────────────────────────────────

  Widget _buildChatStep() {
    // Seed the opening message on first render
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: cs.outline.withValues(alpha: 0.2), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Tutor', style: AppTypography.label),
                  Text(
                    _chatDone
                        ? 'Ready to code!'
                        : 'Up to ${_maxAiResponses - _aiResponseCount} responses left',
                    style: AppTypography.caption
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(),
              // "I'm done" button - always visible
              GestureDetector(
                onTap: () =>
                    context.push('/editor/${_problem.slug}'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _chatDone
                        ? AppColors.primary
                        : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    border: _chatDone
                        ? null
                        : Border.all(
                            color: cs.outline.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'Let\'s code!',
                    style: AppTypography.caption.copyWith(
                      color: _chatDone ? Colors.white : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Message list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            itemCount: _chatMessages.length + (_aiTyping ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _chatMessages.length) {
                return const _TypingBubble();
              }
              final msg = _chatMessages[i];
              return _ChatBubble(msg: msg);
            },
          ),
        ),

        // Input row
        if (!_chatDone)
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(
                    color: cs.outline.withValues(alpha: 0.2), width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    maxLines: 4,
                    minLines: 1,
                    maxLength: 600,
                    enabled: !_aiTyping,
                    textInputAction: TextInputAction.newline,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Type your approach...',
                      hintStyle: AppTypography.body.copyWith(
                          color: cs.onSurfaceVariant
                              .withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _aiTyping ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _aiTyping
                          ? cs.surfaceContainerHighest
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: _aiTyping
                          ? cs.onSurface.withValues(alpha: 0.3)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          // Chat ended - prominent CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: OwlButton(
              label: 'I\'m done - Let\'s code!',
              onPressed: () =>
                  context.push('/editor/${_problem.slug}'),
            ),
          ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _aiTyping) return;

    HapticFeedback.selectionClick();
    _msgController.clear();

    setState(() {
      _chatMessages.add(_ChatMsg(role: 'user', text: text));
      _aiTyping = true;
    });
    _scrollToBottom();

    // Build history for the API (all messages except the one we just added)
    final history = _chatMessages
        .sublist(0, _chatMessages.length - 1) // exclude just-added user msg
        .map((m) => {'role': m.role == 'ai' ? 'model' : m.role, 'text': m.text})
        .toList();

    final isFinal = _aiResponseCount == _maxAiResponses - 1;

    final api = ref.read(apiServiceProvider);
    final result = await api.chatWithTutor(
      problemTitle: _problem.title,
      problemDescription: _problem.description,
      messages: history,
      newMessage: text,
      isFinalRound: isFinal,
    );

    final reply = result['reply'] as String? ?? 'Keep thinking - you\'re on the right track!';

    setState(() {
      _aiTyping = false;
      _chatMessages.add(_ChatMsg(role: 'ai', text: reply));
      _aiResponseCount++;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Step 4: Time to code! ─────────────────────────────────────

  Widget _buildCodePrompt() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.code, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text('Time to Code!', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'You\'ve got the theory down - now implement "${_problem.title}" in the editor.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space10),
          OwlButton(
            label: 'Open Editor',
            onPressed: () =>
                context.push('/editor/${_problem.slug}'),
          ),
          const SizedBox(height: AppSpacing.space4),
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
            ),
            child: Text('Back to home', style: AppTypography.label),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Chat bubble widgets
// ═══════════════════════════════════════════════════════════════

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_outlined,
                  size: 14, color: AppColors.primary),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(
                      isUser ? AppRadius.lg : 4.0),
                  bottomRight: Radius.circular(
                      isUser ? 4.0 : AppRadius.lg),
                ),
              ),
              child: Text(
                msg.text,
                style: AppTypography.body.copyWith(
                  color: isUser ? Colors.white : cs.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_outlined,
                size: 14, color: AppColors.primary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _anim,
                  builder: (ctx, _) {
                    final delay = i * 0.3;
                    final t = ((_anim.value - delay) % 1.0).clamp(0.0, 1.0);
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                            alpha: 0.3 + t * 0.7),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Small reusable widgets
// ═══════════════════════════════════════════════════════════════

class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      Difficulty.easy => ('Easy', AppColors.success),
      Difficulty.medium => ('Medium', AppColors.warning),
      Difficulty.hard => ('Hard', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.caption
            .copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final String label;
  final String content;
  const _ExampleBlock({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption
                .copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            content,
            style: AppTypography.codeBody.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
