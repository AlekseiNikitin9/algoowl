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
import '../../core/services/api_service.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

// ═══════════════════════════════════════════════════════════════
// Snippet model
// ═══════════════════════════════════════════════════════════════

class _Snippet {
  final String trigger;   // prefix user types to trigger this
  final String label;     // shown on the chip
  final String template;  // inserted text
  final int cursorFromEnd; // place cursor N chars from end (0 = at end)

  const _Snippet(this.trigger, this.label, this.template,
      [this.cursorFromEnd = 0]);
}

const _pythonSnippets = [
  _Snippet('for', 'for loop', 'for i in range(n):\n    '),
  _Snippet('if', 'if', 'if :\n    ', 6),
  _Snippet('elif', 'elif', 'elif :\n    ', 6),
  _Snippet('else', 'else', 'else:\n    '),
  _Snippet('while', 'while', 'while :\n    ', 6),
  _Snippet('def', 'def fn', 'def name():\n    return '),
  _Snippet('class', 'class', 'class Name:\n    '),
  _Snippet('return', 'return', 'return '),
  _Snippet('try', 'try/except', 'try:\n    pass\nexcept Exception as e:\n    pass'),
  _Snippet('import', 'import', 'import '),
  _Snippet('lambda', 'lambda', 'lambda x: '),
  _Snippet('print', 'print()', 'print()', 1),
  _Snippet('len', 'len()', 'len()', 1),
  _Snippet('range', 'range()', 'range()', 1),
  _Snippet('dict', '{ }', '{}', 1),
  _Snippet('list', '[ ]', '[]', 1),
  _Snippet('set', 'set()', 'set()', 1),
  _Snippet('sorted', 'sorted()', 'sorted()', 1),
  _Snippet('enumerate', 'enumerate()', 'enumerate()', 1),
  _Snippet('zip', 'zip()', 'zip()', 1),
  _Snippet('map', 'map()', 'map(lambda x: x, )', 1),
  _Snippet('filter', 'filter()', 'filter(lambda x: x, )', 1),
];

const _jsSnippets = [
  _Snippet('for', 'for loop', 'for (let i = 0; i < n; i++) {\n    \n}', 2),
  _Snippet('if', 'if', 'if () {\n    \n}', 8),
  _Snippet('else', 'else', ' else {\n    \n}'),
  _Snippet('while', 'while', 'while () {\n    \n}', 8),
  _Snippet('function', 'function', 'function name() {\n    return;\n}', 11),
  _Snippet('const', 'const', 'const  = ', 3),
  _Snippet('let', 'let', 'let  = ', 3),
  _Snippet('return', 'return', 'return '),
  _Snippet('console', 'console.log', 'console.log()', 1),
  _Snippet('arrow', '() =>', '(x) => x'),
  _Snippet('new', 'new Map()', 'new Map()'),
  _Snippet('set', 'new Set()', 'new Set()'),
  _Snippet('map', '.map()', '.map((x) => x)', 1),
  _Snippet('filter', '.filter()', '.filter((x) => )', 1),
  _Snippet('reduce', '.reduce()', '.reduce((acc, x) => acc, 0)', 2),
  _Snippet('typeof', 'typeof', 'typeof '),
];

// ═══════════════════════════════════════════════════════════════
// Code editor screen
// ═══════════════════════════════════════════════════════════════

class CodeEditorScreen extends ConsumerStatefulWidget {
  final String problemSlug;
  const CodeEditorScreen({super.key, required this.problemSlug});

  @override
  ConsumerState<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends ConsumerState<CodeEditorScreen> {
  late Problem _problem;
  late _SyntaxController _codeController;
  late FocusNode _codeFocusNode;

  String _language = 'python';
  bool _submitted = false;
  bool _correct = false;
  bool _isRunning = false;
  List<_Snippet> _suggestions = [];

  List<_Snippet> get _activeSnippets =>
      _language == 'python' ? _pythonSnippets : _jsSnippets;

  // Returns the word being typed right before the cursor
  String get _currentWord {
    final sel = _codeController.selection;
    if (!sel.isValid || !sel.isCollapsed) return '';
    final text = _codeController.text;
    final offset = sel.baseOffset;
    if (offset == 0) return '';
    int start = offset - 1;
    while (start >= 0 && RegExp(r'\w').hasMatch(text[start])) {
      start--;
    }
    return text.substring(start + 1, offset);
  }

  @override
  void initState() {
    super.initState();
    final problems = ref.read(problemsProvider);
    _problem = problems.firstWhere(
      (p) => p.slug == widget.problemSlug,
      orElse: () => problems.first,
    );
    _codeController = _SyntaxController(_language);
    _codeController.text =
        _problem.starterCode[_language] ?? 'def solve():\n    pass';
    _codeController.addListener(_onCodeChanged);
    _codeFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  void _onCodeChanged() {
    if (!mounted) return;
    final word = _currentWord.toLowerCase();
    final newSugg = word.isEmpty
        ? <_Snippet>[]
        : _activeSnippets
            .where((s) => s.trigger.startsWith(word))
            .toList();
    setState(() => _suggestions = newSugg);
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildProblemHeader(context),
            Expanded(child: _buildCodeCanvas()),
            if (!_submitted) _buildSmartSnippetBar(),
            if (!_submitted) _buildNavBar(),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(Icons.arrow_back, color: cs.onSurface),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(child: OwlProgressBar(progress: 0.65, height: 10)),
          const SizedBox(width: AppSpacing.space3),
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(Icons.close, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Problem header ───────────────────────────────────────────

  Widget _buildProblemHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding, 4, AppSpacing.screenPadding, 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _problem.title,
              style: AppTypography.h3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Details button (opens bottom sheet)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showDetailsSheet(context);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 14, color: cs.onSurface),
                  const SizedBox(width: 4),
                  Text('Details',
                      style: AppTypography.caption
                          .copyWith(color: cs.onSurface)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Language toggle
          _buildLanguageToggle(cs, isDark),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(ColorScheme cs, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['python', 'javascript'].map((lang) {
          final isSelected = _language == lang;
          return GestureDetector(
            onTap: () => _switchLanguage(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                lang == 'python' ? 'Py' : 'JS',
                style: AppTypography.caption.copyWith(
                  color: isSelected ? Colors.white : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _switchLanguage(String lang) {
    if (_language == lang) return;
    HapticFeedback.selectionClick();
    setState(() {
      _language = lang;
      _codeController.setLanguage(lang);
      _codeController.text = _problem.starterCode[lang] ??
          (lang == 'python'
              ? 'def solve():\n    pass'
              : 'function solve() {\n    \n}');
      _suggestions = [];
      _submitted = false;
      _correct = false;
    });
  }

  // ── Code canvas ──────────────────────────────────────────────

  Widget _buildCodeCanvas() {
    final lines = _codeController.text.split('\n');
    final lineNumbers =
        List.generate(lines.length, (i) => '${i + 1}').join('\n');

    return GestureDetector(
      onTap: () => _codeFocusNode.requestFocus(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.space2,
          AppSpacing.screenPadding,
          0,
        ),
        decoration: BoxDecoration(
          color: AppColors.codeBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    lineNumbers,
                    style: AppTypography.codeBody.copyWith(
                      color: AppColors.codeComment,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    readOnly: _submitted,
                    showCursor: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: AppTypography.codeBody.copyWith(fontSize: 13),
                    cursorColor: AppColors.primary,
                    cursorWidth: 2,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Smart snippet bar ────────────────────────────────────────
  // Suggestions matching current word are shown first and highlighted.
  // Remaining snippets follow as dimmer quick-access chips.

  Widget _buildSmartSnippetBar() {
    final suggested = _suggestions;
    final others = _activeSnippets
        .where((s) => !suggested.contains(s))
        .toList();
    final all = [...suggested, ...others];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding, vertical: 4),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (ctx, i) {
          final snippet = all[i];
          final isHighlighted = suggested.contains(snippet);
          return _SnippetChip(
            snippet: snippet,
            highlighted: isHighlighted,
            onTap: () {
              HapticFeedback.selectionClick();
              _insertSnippet(snippet);
            },
          );
        },
      ),
    );
  }

  // ── Navigation bar (arrow keys + Tab + Enter) ────────────────

  Widget _buildNavBar() {
    return Container(
      height: 40,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          _NavKey(icon: Icons.arrow_back, onTap: () => _moveCursor(-1)),
          _NavKey(icon: Icons.arrow_forward, onTap: () => _moveCursor(1)),
          _NavKey(icon: Icons.arrow_upward, onTap: () => _moveCursorVertical(-1)),
          _NavKey(icon: Icons.arrow_downward, onTap: () => _moveCursorVertical(1)),
          const SizedBox(width: 6),
          _NavKey(label: 'Tab', onTap: () => _insertAtCursor('    ')),
          _NavKey(
              icon: Icons.keyboard_return,
              onTap: () => _insertAtCursor('\n')),
          const Spacer(),
          // Backspace
          _NavKey(
              icon: Icons.backspace_outlined,
              onTap: () {
                final sel = _codeController.selection;
                if (!sel.isValid || sel.baseOffset == 0) return;
                final text = _codeController.text;
                final start = sel.isCollapsed ? sel.baseOffset - 1 : sel.start;
                final end = sel.end;
                final newText = text.replaceRange(start, end, '');
                _codeController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: start),
                );
              }),
        ],
      ),
    );
  }

  // ── Bottom actions (Hint | Run | Check/Continue) ─────────────

  Widget _buildBottomActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        8,
        AppSpacing.screenPadding,
        AppSpacing.space4,
      ),
      child: Row(
        children: [
          if (!_submitted) ...[
            // Hint icon button
            _IconAction(
              icon: Icons.lightbulb_outline,
              color: AppColors.warning,
              onTap: () => _showHintSheet(context),
            ),
            const SizedBox(width: 8),
            // Run custom test button
            _IconAction(
              icon: Icons.play_circle_outline,
              color: AppColors.primary,
              onTap: _isRunning ? null : () => _showCustomRunSheet(context),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: OwlButton(
              label: _submitted
                  ? (_correct ? 'Continue' : 'Try Again')
                  : 'Submit',
              backgroundColor:
                  _submitted && _correct ? AppColors.success : null,
              shadowColor:
                  _submitted && _correct ? AppColors.successDark : null,
              isLoading: _isRunning,
              onPressed: _isRunning
                  ? null
                  : () {
                      if (_submitted) {
                        if (_correct) {
                          context.pop();
                        } else {
                          setState(() {
                            _submitted = false;
                            _correct = false;
                          });
                        }
                      } else {
                        _submit();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  // ── Cursor helpers ───────────────────────────────────────────

  void _insertAtCursor(String text) {
    final sel = _codeController.selection;
    if (!sel.isValid) {
      _codeController.text += text;
      return;
    }
    final current = _codeController.text;
    final newText = current.replaceRange(sel.start, sel.end, text);
    final newOffset = sel.start + text.length;
    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _insertSnippet(_Snippet snippet) {
    final word = _currentWord;
    final sel = _codeController.selection;
    if (!sel.isValid) return;
    final text = _codeController.text;
    final cursorPos = sel.baseOffset;
    final wordStart = cursorPos - word.length;

    final newText =
        text.replaceRange(wordStart, cursorPos, snippet.template);
    final newCursor =
        wordStart + snippet.template.length - snippet.cursorFromEnd;

    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor.clamp(0, newText.length)),
    );
  }

  void _moveCursor(int delta) {
    final sel = _codeController.selection;
    if (!sel.isValid) return;
    final newOffset =
        (sel.baseOffset + delta).clamp(0, _codeController.text.length);
    _codeController.selection =
        TextSelection.collapsed(offset: newOffset);
  }

  void _moveCursorVertical(int lineDelta) {
    final text = _codeController.text;
    final offset = _codeController.selection.baseOffset;
    if (!_codeController.selection.isValid) return;

    final beforeCursor = text.substring(0, offset);
    final linesBefore = beforeCursor.split('\n');
    final currentLine = linesBefore.length - 1;
    final currentCol = linesBefore.last.length;

    final allLines = text.split('\n');
    final targetLine =
        (currentLine + lineDelta).clamp(0, allLines.length - 1);
    if (targetLine == currentLine) return;

    final targetCol = currentCol.clamp(0, allLines[targetLine].length);
    int newOffset = 0;
    for (int i = 0; i < targetLine; i++) {
      newOffset += allLines[i].length + 1;
    }
    newOffset += targetCol;

    _codeController.selection =
        TextSelection.collapsed(offset: newOffset);
  }

  // ── Submit ───────────────────────────────────────────────────

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    _codeFocusNode.unfocus();
    setState(() => _isRunning = true);

    final api = ref.read(apiServiceProvider);
    Map<String, dynamic> result;

    try {
      result = await api.submitCode(
        problemSlug: _problem.slug,
        language: _language,
        code: _codeController.text,
      );
    } on ApiException catch (e) {
      result = {
        'status': 'runtime_error',
        'test_cases_passed': 0,
        'test_cases_total': 0,
        'error': e.message,
        'test_results': [],
      };
    } catch (e) {
      result = {
        'status': 'runtime_error',
        'test_cases_passed': 0,
        'test_cases_total': 0,
        'error': e.toString(),
        'test_results': [],
      };
    }

    final accepted = result['status'] == 'accepted';

    setState(() {
      _isRunning = false;
      _submitted = true;
      _correct = accepted;
    });

    if (!mounted) return;
    if (accepted) {
      ref.read(userProfileProvider.notifier).addXp(15);
      showXpToast(context, 15);
    }

    _showResultSheet(context, result);
  }

  // ── Sheets ───────────────────────────────────────────────────

  void _showDetailsSheet(BuildContext context) {
    final visibleCases =
        _problem.testCases.where((tc) => !tc.isHidden).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (ctx, scrollCtrl) {
          return DefaultTabController(
            length: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_problem.title,
                              style: AppTypography.h3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        _difficultyPill(
                            _problem.difficulty),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Theme.of(ctx)
                        .colorScheme
                        .onSurfaceVariant,
                    tabs: const [
                      Tab(text: 'Problem'),
                      Tab(text: 'Examples'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // ── Problem tab
                        ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(_problem.description,
                                style: AppTypography.body),
                            if (_problem.constraints.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text('Constraints',
                                  style: AppTypography.label),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.codeBg,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Text(
                                  _problem.constraints,
                                  style: AppTypography.codeBody
                                      .copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // ── Examples tab
                        ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(20),
                          children: visibleCases.isEmpty
                              ? [
                                  Text('No public examples.',
                                      style: AppTypography.body)
                                ]
                              : visibleCases
                                  .asMap()
                                  .entries
                                  .map((e) {
                                    final tc = e.value;
                                    final n = e.key + 1;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Example $n',
                                              style: AppTypography.label),
                                          const SizedBox(height: 8),
                                          _CodeBlock(
                                              label: 'Input',
                                              content: tc.input),
                                          const SizedBox(height: 6),
                                          _CodeBlock(
                                              label: 'Output',
                                              content: tc.expectedOutput),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showResultSheet(BuildContext context, Map<String, dynamic> result) {
    final status = result['status'] as String? ?? 'runtime_error';
    final passed = result['test_cases_passed'] as int? ?? 0;
    final total = result['test_cases_total'] as int? ?? 0;
    final runtimeMs = result['runtime_ms'] as int?;
    final errorMsg = result['error'] as String?;
    final stdout = result['stdout'] as String?;
    final testResults = List<Map<String, dynamic>>.from(
        result['test_results'] as List? ?? []);

    final isAccepted = status == 'accepted';
    final statusColor = switch (status) {
      'accepted' => AppColors.success,
      'wrong_answer' => AppColors.error,
      'time_limit' => AppColors.warning,
      _ => AppColors.error,
    };
    final statusLabel = switch (status) {
      'accepted' => 'Accepted',
      'wrong_answer' => 'Wrong Answer',
      'time_limit' => 'Time Limit Exceeded',
      'runtime_error' => 'Runtime Error',
      _ => status,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        final bottomPad = MediaQuery.of(ctx).viewPadding.bottom;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6 + bottomPad,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                    vertical: AppSpacing.space3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAccepted ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Text(
                      statusLabel,
                      style: AppTypography.bodyLg.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (runtimeMs != null)
                      Text('${runtimeMs}ms',
                          style: AppTypography.caption
                              .copyWith(color: statusColor)),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.space4),
              Text('Test cases: $passed / $total passed',
                  style: AppTypography.label),

              // stdout / console output
              if (stdout != null && stdout.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space4),
                Text('Console Output', style: AppTypography.label),
                const SizedBox(height: AppSpacing.space2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.codeBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    stdout,
                    style: AppTypography.codeBody.copyWith(fontSize: 12),
                  ),
                ),
              ],

              // Error message
              if (errorMsg != null && !isAccepted) ...[
                const SizedBox(height: AppSpacing.space3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.codeBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    errorMsg,
                    style: AppTypography.codeBody
                        .copyWith(fontSize: 12, color: AppColors.error),
                  ),
                ),
              ],

              // First failing test case
              if (!isAccepted && testResults.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space4),
                Text('First Failure', style: AppTypography.label),
                const SizedBox(height: AppSpacing.space2),
                () {
                  final fail = testResults.firstWhere(
                    (t) => t['passed'] != true,
                    orElse: () => testResults.first,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CodeBlock(
                          label: 'Input',
                          content: fail['input']?.toString() ?? ''),
                      const SizedBox(height: AppSpacing.space2),
                      _CodeBlock(
                          label: 'Expected',
                          content: fail['expected']?.toString() ?? ''),
                      const SizedBox(height: AppSpacing.space2),
                      _CodeBlock(
                          label: 'Got',
                          content: fail['actual']?.toString() ?? '-'),
                    ],
                  );
                }(),
              ],

              const SizedBox(height: AppSpacing.space6),
              OwlButton(
                label: isAccepted ? 'Continue' : 'Try Again',
                backgroundColor:
                    isAccepted ? AppColors.success : null,
                shadowColor:
                    isAccepted ? AppColors.successDark : null,
                onPressed: () {
                  Navigator.pop(ctx);
                  if (isAccepted) context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHintSheet(BuildContext context) {
    final hints = _problem.hints;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        final bottomPad = MediaQuery.of(ctx).viewPadding.bottom;
        int hintLevel = 0;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.space6,
                AppSpacing.space6,
                AppSpacing.space6,
                AppSpacing.space6 + bottomPad,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppColors.warning, size: 24),
                      const SizedBox(width: 8),
                      Text('Hints', style: AppTypography.h2),
                      const Spacer(),
                      if (hints.isNotEmpty)
                        Text(
                          '${hintLevel + 1} / ${hints.length}',
                          style: AppTypography.caption.copyWith(
                              color: Theme.of(ctx)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  if (hints.isEmpty)
                    Text(
                      'Think about what data structure gives you O(1) lookups. '
                      'Walk through the array once, storing what you\'ve seen.',
                      style: AppTypography.body,
                    )
                  else
                    ...List.generate(
                      hintLevel + 1,
                      (i) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.space3),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.space3),
                          decoration: BoxDecoration(
                            color: AppColors.warning
                                .withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: AppColors.warning
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(hints[i],
                              style: AppTypography.body),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.space4),
                  Row(
                    children: [
                      if (hints.isNotEmpty &&
                          hintLevel < hints.length - 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setSheetState(() => hintLevel++),
                            style: OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppRadius.xxl),
                              ),
                            ),
                            child: Text('Next Hint',
                                style: AppTypography.label),
                          ),
                        ),
                      if (hints.isNotEmpty &&
                          hintLevel < hints.length - 1)
                        const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: OwlButton(
                          label: 'Got it',
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomRunSheet(BuildContext context) {
    final inputCtrl = TextEditingController(
      text: _problem.testCases.isNotEmpty
          ? _problem.testCases.first.input
          : '',
    );
    bool running = false;
    Map<String, dynamic>? runResult;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        final bottomPad = MediaQuery.of(ctx).viewPadding.bottom +
            MediaQuery.of(ctx).viewInsets.bottom;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.space6,
                AppSpacing.space6,
                AppSpacing.space6,
                AppSpacing.space6 + bottomPad,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text('Custom Test', style: AppTypography.h2),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text('Input', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.space2),
                  TextField(
                    controller: inputCtrl,
                    maxLines: 3,
                    style: AppTypography.codeBody.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.codeBg,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  if (runResult != null) ...[
                    const SizedBox(height: AppSpacing.space4),
                    if ((runResult!['stdout'] as String? ?? '')
                        .isNotEmpty) ...[
                      Text('Console', style: AppTypography.label),
                      const SizedBox(height: AppSpacing.space2),
                      _CodeBlock(
                          label: '',
                          content: runResult!['stdout'] as String),
                      const SizedBox(height: AppSpacing.space3),
                    ],
                    Text('Output', style: AppTypography.label),
                    const SizedBox(height: AppSpacing.space2),
                    _CodeBlock(
                      label: runResult!['status'] as String? ?? '',
                      content: runResult!['actual'] as String? ??
                          runResult!['error'] as String? ??
                          '-',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space5),
                  OwlButton(
                    label: running ? 'Running…' : 'Run',
                    isLoading: running,
                    onPressed: running
                        ? null
                        : () async {
                            setSheetState(() {
                              running = true;
                              runResult = null;
                            });
                            final api = ref.read(apiServiceProvider);
                            final res = await api.runCustomTest(
                              language: _language,
                              code: _codeController.text,
                              testInput: inputCtrl.text,
                            );
                            setSheetState(() {
                              running = false;
                              runResult = res;
                            });
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _difficultyPill(Difficulty d) {
    final (label, color) = switch (d) {
      Difficulty.easy => ('Easy', AppColors.success),
      Difficulty.medium => ('Medium', AppColors.warning),
      Difficulty.hard => ('Hard', AppColors.error),
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label,
          style: AppTypography.caption.copyWith(
              color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Multi-language syntax-highlighting controller
// ═══════════════════════════════════════════════════════════════

class _SyntaxController extends TextEditingController {
  static const _pyKeywords = {
    'def', 'for', 'in', 'if', 'else', 'elif', 'return', 'while', 'class',
    'import', 'from', 'pass', 'break', 'continue', 'and', 'or', 'not',
    'True', 'False', 'None', 'range', 'len', 'self', 'lambda', 'yield',
    'with', 'as', 'try', 'except', 'finally', 'raise', 'assert', 'global',
    'nonlocal', 'is', 'print', 'sorted', 'enumerate', 'zip', 'map', 'filter',
  };

  static const _jsKeywords = {
    'function', 'const', 'let', 'var', 'return', 'if', 'else', 'for',
    'while', 'do', 'switch', 'case', 'break', 'continue', 'new', 'class',
    'extends', 'import', 'export', 'default', 'this', 'typeof', 'instanceof',
    'null', 'undefined', 'true', 'false', 'try', 'catch', 'finally', 'throw',
    'async', 'await', 'of', 'in', 'from', 'console', 'map', 'filter',
    'reduce', 'forEach', 'length', 'push', 'pop', 'shift', 'unshift',
  };

  String _language;

  _SyntaxController(this._language);

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  Set<String> get _keywords =>
      _language == 'python' ? _pyKeywords : _jsKeywords;

  static final _tokenPattern = RegExp(
    r'(#[^\n]*|\/\/[^\n]*)'     // comments (py + js)
    r"|('(?:[^'\\]|\\.)*'|"
    r'"(?:[^"\\]|\\.)*"'
    r'|`(?:[^`\\]|\\.)*`)'      // strings + template literals
    r'|(\b\d+(?:\.\d+)?\b)'     // numbers
    r'|(\b\w+\b)'               // identifiers / keywords
    r'|(\s+)'
    r'|(.)',
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = AppTypography.codeBody.copyWith(fontSize: 13);
    final spans = <TextSpan>[];

    for (final match in _tokenPattern.allMatches(text)) {
      final m = match.group(0)!;
      TextStyle ts;
      if (match.group(1) != null) {
        ts = base.copyWith(color: AppColors.codeComment);
      } else if (match.group(2) != null) {
        ts = base.copyWith(color: AppColors.codeString);
      } else if (match.group(3) != null) {
        ts = base.copyWith(color: AppColors.codeNumber);
      } else if (match.group(4) != null && _keywords.contains(m)) {
        ts = AppTypography.codeKeyword.copyWith(fontSize: 13);
      } else {
        ts = base;
      }
      spans.add(TextSpan(text: m, style: ts));
    }

    if (spans.isEmpty) spans.add(TextSpan(text: text, style: base));
    return TextSpan(children: spans, style: style);
  }
}

// ═══════════════════════════════════════════════════════════════
// Small UI components
// ═══════════════════════════════════════════════════════════════

class _SnippetChip extends StatelessWidget {
  final _Snippet snippet;
  final bool highlighted;
  final VoidCallback onTap;

  const _SnippetChip({
    required this.snippet,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.primary
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: highlighted
              ? null
              : Border.all(color: cs.outline.withValues(alpha: 0.6)),
        ),
        child: Text(
          snippet.label,
          style: AppTypography.label.copyWith(
            color: highlighted ? Colors.white : cs.onSurface,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _NavKey extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;

  const _NavKey({this.icon, this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          height: 32,
          constraints: const BoxConstraints(minWidth: 36),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: onTap == null
                ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
                color: cs.outline.withValues(alpha: 0.5), width: 0.5),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 16,
                  color: onTap == null
                      ? cs.onSurface.withValues(alpha: 0.3)
                      : cs.onSurface)
              : Text(label!,
                  style: AppTypography.label
                      .copyWith(fontSize: 11, color: cs.onSurface)),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
        ),
        child: Icon(icon,
            color: onTap == null
                ? color.withValues(alpha: 0.3)
                : color,
            size: 22),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String label;
  final String content;

  const _CodeBlock({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.codeBg,
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
