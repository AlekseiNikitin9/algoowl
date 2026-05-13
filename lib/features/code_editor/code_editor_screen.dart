import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/code_dust.dart';
import '../../core/widgets/owl_button.dart';
import '../../core/services/api_service.dart';
import '../../models/problem.dart';
import '../../providers/app_providers.dart';

// ═══════════════════════════════════════════════════════════════
// Snippet model
// ═══════════════════════════════════════════════════════════════

class _Snippet {
  final String trigger;
  final String label;
  final String template;
  final int cursorFromEnd;

  const _Snippet(this.trigger, this.label, this.template,
      [this.cursorFromEnd = 0]);
}

const _pythonSnippets = [
  _Snippet('for', 'for', 'for i in range(n):\n    '),
  _Snippet('if', 'if', 'if :\n    ', 6),
  _Snippet('elif', 'elif', 'elif :\n    ', 6),
  _Snippet('else', 'else', 'else:\n    '),
  _Snippet('while', 'while', 'while :\n    ', 6),
  _Snippet('def', 'def', 'def name():\n    return '),
  _Snippet('class', 'class', 'class Name:\n    '),
  _Snippet('return', 'return', 'return '),
  _Snippet('print', 'print', 'print()', 1),
  _Snippet('len', 'len', 'len()', 1),
  _Snippet('range', 'range', 'range()', 1),
  _Snippet('dict', '{ }', '{}', 1),
  _Snippet('list', '[ ]', '[]', 1),
  _Snippet('set', 'set', 'set()', 1),
  _Snippet('sorted', 'sorted', 'sorted()', 1),
  _Snippet('enumerate', 'enumerate', 'enumerate()', 1),
  _Snippet('zip', 'zip', 'zip()', 1),
];

const _jsSnippets = [
  _Snippet('for', 'for', 'for (let i = 0; i < n; i++) {\n    \n}', 2),
  _Snippet('if', 'if', 'if () {\n    \n}', 8),
  _Snippet('else', 'else', ' else {\n    \n}'),
  _Snippet('while', 'while', 'while () {\n    \n}', 8),
  _Snippet('function', 'fn', 'function name() {\n    return;\n}', 11),
  _Snippet('const', 'const', 'const  = ', 3),
  _Snippet('let', 'let', 'let  = ', 3),
  _Snippet('return', 'return', 'return '),
  _Snippet('console', 'log', 'console.log()', 1),
  _Snippet('arrow', '=>', '(x) => x'),
  _Snippet('map', 'Map', 'new Map()'),
  _Snippet('set', 'Set', 'new Set()'),
];

// ═══════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════

class CodeEditorScreen extends ConsumerStatefulWidget {
  final String problemSlug;
  const CodeEditorScreen({super.key, required this.problemSlug});

  @override
  ConsumerState<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends ConsumerState<CodeEditorScreen> {
  late Problem _problem;
  _SyntaxController? _code;
  late FocusNode _focus;
  bool _loading = true;

  String _lang = 'python';
  bool _showHint = false;
  bool _running = false;
  bool _runningTest = false;
  String? _status; // 'passed' | 'failed' | null
  int? _passed;
  int? _total;
  String? _errorMsg;
  Map<String, dynamic>? _runResult;
  List<_Snippet> _suggestions = const [];
  bool _showDust = false;

  final _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  List<_Snippet> get _activeSnippets =>
      _lang == 'python' ? _pythonSnippets : _jsSnippets;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _loadProblem();
  }

  Future<void> _loadProblem() async {
    // Check local sample problems first (instant, no network)
    Problem? result;
    for (final p in kSampleProblems) {
      if (p.slug == widget.problemSlug) { result = p; break; }
    }

    if (result == null) {
      try {
        final api = ref.read(apiServiceProvider);
        await api.ensureAuth();
        final data = await api.getProblem(widget.problemSlug);
        // Merge API data with any local lesson content for this slug
        Problem? local;
        final slug = data['slug'] as String? ?? widget.problemSlug;
        for (final p in kSampleProblems) {
          if (p.slug == slug) { local = p; break; }
        }
        result = Problem.fromApi(data, local: local);
      } catch (_) {
        result = kSampleProblems.first;
      }
    }

    if (!mounted) return;
    setState(() {
      _problem = result!;
      _code = _SyntaxController(_lang);
      _code!.text = _problem.starterCode[_lang] ?? 'def solve():\n    pass';
      _code!.addListener(_onCodeChanged);
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _removeOverlay();
    _code?.removeListener(_onCodeChanged);
    _code?.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _currentWord {
    final sel = _code!.selection;
    if (!sel.isValid || !sel.isCollapsed) return '';
    final text = _code!.text;
    final offset = sel.baseOffset;
    if (offset == 0) return '';
    int start = offset - 1;
    while (start >= 0 && RegExp(r'\w').hasMatch(text[start])) {
      start--;
    }
    return text.substring(start + 1, offset);
  }

  void _onCodeChanged() {
    if (!mounted) return;
    final word = _currentWord.toLowerCase();
    final next = word.isEmpty
        ? const <_Snippet>[]
        : _activeSnippets.where((s) => s.trigger.startsWith(word)).toList();
    if (!_listEquals(next, _suggestions)) {
      _suggestions = next;
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateOverlay());
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Offset? _getCursorScreenPos() {
    final ctx = _textFieldKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final offset = _code!.selection.baseOffset.clamp(0, _code!.text.length);
    final textUpToCursor = _code!.text.substring(0, offset);
    final lines = textUpToCursor.split('\n');
    final cursorLine = lines.length - 1;
    final lastLine = lines.last;

    final style = AppTypography.codeBody.copyWith(fontSize: 13, height: 20 / 13);
    final painter = TextPainter(
      text: TextSpan(text: lastLine, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    final cursorLocalX = painter.width;
    painter.dispose();

    const lineHeight = 20.0;
    final cursorLocalY = cursorLine * lineHeight;
    return box.localToGlobal(Offset(cursorLocalX, cursorLocalY));
  }

  void _updateOverlay() {
    if (!mounted) return;
    if (_suggestions.isEmpty || _status != null) {
      _removeOverlay();
      return;
    }

    final pos = _getCursorScreenPos();
    if (pos == null) {
      _removeOverlay();
      return;
    }

    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const popupWidth = 164.0;
    const lineHeight = 20.0;
    final left = (pos.dx + 10).clamp(0.0, screenSize.width - popupWidth);
    final top = pos.dy + lineHeight;

    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final popupBg = isDark ? AppColors.codeBgAlt : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final snaps = _suggestions;
        return Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: popupWidth,
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: popupBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: snaps.length,
                itemBuilder: (_, i) {
                  final s = snaps[i];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _removeOverlay();
                      _insertSnippet(s);
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.label,
                              style: AppTypography.codeBody.copyWith(
                                fontSize: 12,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.trigger == s.label ? 'kw' : 'fn',
                              style: AppTypography.codeBody.copyWith(
                                fontSize: 10,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _switchLang(String lang) {
    if (_lang == lang) return;
    HapticFeedback.selectionClick();
    _removeOverlay();
    setState(() {
      _lang = lang;
      _code!.setLanguage(lang);
      _code!.text = _problem.starterCode[lang] ??
          (lang == 'python'
              ? 'def solve():\n    pass'
              : 'function solve() {\n    \n}');
      _suggestions = const [];
      _status = null;
      _showDust = false;
    });
  }

  void _insertSnippet(_Snippet s) {
    final word = _currentWord;
    final sel = _code!.selection;
    if (!sel.isValid) return;
    final text = _code!.text;
    final cursor = sel.baseOffset;
    final start = cursor - word.length;
    final newText = text.replaceRange(start, cursor, s.template);
    final newCursor = start + s.template.length - s.cursorFromEnd;
    _code!.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: newCursor.clamp(0, newText.length)),
    );
  }

  Future<void> _runTest() async {
    HapticFeedback.mediumImpact();
    _removeOverlay();
    setState(() { _runningTest = true; _runResult = null; });

    final firstTest = _problem.testCases.where((t) => !t.isHidden).firstOrNull;
    final api = ref.read(apiServiceProvider);
    try {
      final result = await api.runCustomTest(
        language: _lang,
        code: _code!.text,
        testInput: firstTest?.input ?? '',
        expectedOutput: firstTest?.expectedOutput ?? '',
      );
      if (!mounted) return;
      setState(() { _runningTest = false; _runResult = result; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _runningTest = false;
        _runResult = {'status': 'error', 'error': 'Server unavailable — start the backend to run tests.'};
      });
    }
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    _focus.unfocus();
    _removeOverlay();
    setState(() { _running = true; _runResult = null; });

    final api = ref.read(apiServiceProvider);
    Map<String, dynamic> result;
    try {
      result = await api.submitCode(
        problemSlug: _problem.slug,
        language: _lang,
        code: _code!.text,
      );
    } on ApiException catch (e) {
      result = {
        'status': 'runtime_error',
        'test_cases_passed': 0,
        'test_cases_total': 0,
        'error': e.message,
      };
    } catch (_) {
      result = {
        'status': 'runtime_error',
        'test_cases_passed': 0,
        'test_cases_total': 0,
        'error': 'Server unavailable — start the backend to submit.',
      };
    }

    final accepted = result['status'] == 'accepted';
    if (!mounted) return;

    setState(() {
      _running = false;
      _status = accepted ? 'passed' : 'failed';
      _passed = result['test_cases_passed'] as int?;
      _total = result['test_cases_total'] as int?;
      _errorMsg = result['error'] as String?;
      if (accepted) _showDust = true;
    });

    if (accepted) {
      ref.read(userProfileProvider.notifier).addXp(15);
      ref.invalidate(solvedSlugsProvider);
      ref.invalidate(categoryStatusDataProvider);
    }
  }

  Future<void> _openResults() async {
    final api = ref.read(apiServiceProvider);
    final complexity = await api.analyzeComplexity(
      code: _code!.text,
      language: _lang,
    );
    if (!mounted) return;
    context.push('/accepted/${_problem.slug}', extra: complexity);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.codeBg : Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(
                  problem: _problem,
                  lang: _lang,
                  onClose: () => context.pop(),
                  onSwitchLang: _switchLang,
                ),
                _PromptStrip(
                  problem: _problem,
                  showHint: _showHint,
                  onToggleHint: () => setState(() => _showHint = !_showHint),
                ),
                if (_showHint && _problem.hints.isNotEmpty) _HintBanner(text: _problem.hints.first),
                Expanded(child: _CodeCanvas(
                  controller: _code!,
                  focus: _focus,
                  textFieldKey: _textFieldKey,
                )),
                if (_runResult != null) _RunBanner(result: _runResult!),
                if (_status == 'failed') _FailureBanner(
                  passed: _passed,
                  total: _total,
                  message: _errorMsg,
                ),
                _SubmitBar(
                  status: _status,
                  running: _running,
                  runningTest: _runningTest,
                  onSubmit: _submit,
                  onRunTest: _runTest,
                  onViewResults: _openResults,
                  onDismissKeyboard: () => _focus.unfocus(),
                ),
              ],
            ),
          ),
          if (_showDust)
            Positioned.fill(
              child: CodeDustOverlay(show: _showDust),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Top bar
// ═══════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final Problem problem;
  final String lang;
  final VoidCallback onClose;
  final ValueChanged<String> onSwitchLang;

  const _TopBar({
    required this.problem,
    required this.lang,
    required this.onClose,
    required this.onSwitchLang,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : scheme.onSurface;
    final eyebrowColor = contentColor.withValues(alpha: 0.45);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : scheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          _SquareBtn(
            icon: CkIcon.close(
              size: 17,
              color: contentColor.withValues(alpha: 0.75),
            ),
            onTap: onClose,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${problem.categoryId.toUpperCase()} · ${_diffLabel(problem.difficulty)}',
                  style: AppTypography.codeBody.copyWith(
                    color: eyebrowColor,
                    fontSize: 11,
                    letterSpacing: 0.06 * 11,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  problem.title,
                  style: AppTypography.h3.copyWith(
                    color: contentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _LangToggle(lang: lang, onSwitch: onSwitchLang),
        ],
      ),
    );
  }

  static String _diffLabel(Difficulty d) => switch (d) {
        Difficulty.easy => 'EASY',
        Difficulty.medium => 'MEDIUM',
        Difficulty.hard => 'HARD',
      };
}

class _SquareBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  const _SquareBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : scheme.outline,
          ),
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}

class _LangToggle extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onSwitch;
  const _LangToggle({required this.lang, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : scheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langBtn('python', 'Py', scheme, isDark),
          _langBtn('javascript', 'JS', scheme, isDark),
        ],
      ),
    );
  }

  Widget _langBtn(String key, String label, ColorScheme scheme, bool isDark) {
    final active = lang == key;
    final activeColor = isDark ? Colors.white : AppColors.primary;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : scheme.onSurfaceVariant;
    return GestureDetector(
      onTap: () => onSwitch(key),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 28,
        constraints: const BoxConstraints(minWidth: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.codeBody.copyWith(
            color: active ? activeColor : inactiveColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Prompt strip + hint
// ═══════════════════════════════════════════════════════════════

class _PromptStrip extends StatefulWidget {
  final Problem problem;
  final bool showHint;
  final VoidCallback onToggleHint;

  const _PromptStrip({
    required this.problem,
    required this.showHint,
    required this.onToggleHint,
  });

  @override
  State<_PromptStrip> createState() => _PromptStripState();
}

class _PromptStripState extends State<_PromptStrip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : scheme.onSurface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : scheme.outline.withValues(alpha: 0.5);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.problem.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: contentColor.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: contentColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onToggleHint();
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: widget.showHint
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : scheme.surfaceContainerHighest),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: widget.showHint
                          ? AppColors.gold.withValues(alpha: 0.4)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : scheme.outline),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CkIcon.hint(
                        size: 13,
                        color: widget.showHint
                            ? AppColors.gold
                            : contentColor.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hint',
                        style: AppTypography.caption.copyWith(
                          color: widget.showHint
                              ? AppColors.gold
                              : contentColor.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_expanded)
          _ExpandedDescription(
            problem: widget.problem,
            isDark: isDark,
            scheme: scheme,
          ),
      ],
    );
  }
}

class _ExpandedDescription extends StatelessWidget {
  final Problem problem;
  final bool isDark;
  final ColorScheme scheme;

  const _ExpandedDescription({
    required this.problem,
    required this.isDark,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final contentColor = isDark ? Colors.white : scheme.onSurface;
    final examples = problem.testCases.where((t) => !t.isHidden).take(2).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : scheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            problem.description,
            style: AppTypography.body.copyWith(
              color: contentColor.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'EXAMPLES',
              style: AppTypography.eyebrow.copyWith(
                color: contentColor.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            for (final tc in examples)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'in  ',
                        style: AppTypography.codeBody.copyWith(
                          fontSize: 11,
                          color: contentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tc.input,
                          style: AppTypography.codeBody.copyWith(
                            fontSize: 11,
                            color: contentColor.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'out ',
                        style: AppTypography.codeBody.copyWith(
                          fontSize: 11,
                          color: contentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      Text(
                        tc.expectedOutput,
                        style: AppTypography.codeBody.copyWith(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.codeString
                              : const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String text;
  const _HintBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Code canvas with gutter
// ═══════════════════════════════════════════════════════════════

class _CodeCanvas extends StatelessWidget {
  final _SyntaxController controller;
  final FocusNode focus;
  final GlobalKey textFieldKey;

  const _CodeCanvas({
    required this.controller,
    required this.focus,
    required this.textFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focus.requestFocus(),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Gutter(controller: controller),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                child: TextField(
                  key: textFieldKey,
                  controller: controller,
                  focusNode: focus,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: AppTypography.codeBody.copyWith(fontSize: 13),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  cursorWidth: 2,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gutter extends StatelessWidget {
  final TextEditingController controller;
  const _Gutter({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gutterBg = isDark ? AppColors.codeBgAlt : const Color(0xFFEAEDF4);
    final lineNumColor = isDark
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.textDisabled;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final lines = controller.text.split('\n').length;
        return Container(
          width: 38,
          color: gutterBg,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              lines,
              (i) => SizedBox(
                height: 20,
                child: Text(
                  '${i + 1}',
                  style: AppTypography.codeBody.copyWith(
                    color: lineNumColor,
                    fontSize: 12,
                    height: 20 / 12,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Submit bar + failure banner
// ═══════════════════════════════════════════════════════════════

class _FailureBanner extends StatelessWidget {
  final int? passed;
  final int? total;
  final String? message;

  const _FailureBanner({this.passed, this.total, this.message});

  @override
  Widget build(BuildContext context) {
    final text = message != null && message!.isNotEmpty
        ? message!
        : '${(total ?? 3) - (passed ?? 0)} of ${total ?? 3} tests failed — check your return path.';
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorDark.withValues(alpha: 0.4),
            offset: const Offset(0, 10),
            blurRadius: 28,
          ),
        ],
      ),
      child: Row(
        children: [
          const CkIcon.close(size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunBanner extends StatelessWidget {
  final Map<String, dynamic> result;
  const _RunBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final status = result['status'] as String? ?? 'error';
    final actual = result['actual']?.toString();
    final error = result['error']?.toString();
    final isOk = status == 'accepted';

    String text;
    if (error != null && error.isNotEmpty) {
      text = error;
    } else if (actual != null) {
      text = 'Output: $actual';
    } else {
      text = isOk ? 'Test passed!' : 'Test failed';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isOk
            ? AppColors.successDark
            : AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: isOk
            ? null
            : Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          isOk
              ? const CkIcon.check(size: 16, color: Colors.white)
              : const CkIcon.run(size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: isOk ? Colors.white : AppColors.gold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  final String? status;
  final bool running;
  final bool runningTest;
  final VoidCallback onSubmit;
  final VoidCallback onRunTest;
  final VoidCallback onViewResults;
  final VoidCallback onDismissKeyboard;

  const _SubmitBar({
    required this.status,
    required this.running,
    required this.runningTest,
    required this.onSubmit,
    required this.onRunTest,
    required this.onViewResults,
    required this.onDismissKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : scheme.onSurface;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final isPassed = status == 'passed';
    final isFailed = status == 'failed';

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? AppColors.codeBg : scheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : scheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: isPassed
          ? OwlButton.success(
              label: 'View Results',
              onPressed: onViewResults,
              leading: const CkIcon.chevR(size: 18, color: Colors.white),
            )
          : Row(
              children: [
                _SquareBtn(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: contentColor.withValues(alpha: 0.65),
                    size: 20,
                  ),
                  onTap: onDismissKeyboard,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (running || runningTest) ? null : onRunTest,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: runningTest ? 0.04 : 0.07)
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : scheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (runningTest)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: contentColor.withValues(alpha: 0.65),
                            ),
                          )
                        else
                          CkIcon.run(
                            size: 14,
                            color: contentColor.withValues(alpha: 0.75),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          runningTest ? 'Running…' : 'Run',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: contentColor.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OwlButton(
                    label: running
                        ? 'Running…'
                        : isFailed
                            ? 'Try Again'
                            : 'Submit',
                    isLoading: running,
                    onPressed: running ? null : onSubmit,
                    leading: running
                        ? null
                        : const CkIcon.check(size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Syntax highlighting controller (unchanged)
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
    'async', 'await', 'of', 'in', 'from', 'console',
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
    r'(#[^\n]*|\/\/[^\n]*)'
    r"|('(?:[^'\\]|\\.)*'|"
    r'"(?:[^"\\]|\\.)*"'
    r'|`(?:[^`\\]|\\.)*`)'
    r'|(\b\d+(?:\.\d+)?\b)'
    r'|(\b\w+\b)'
    r'|(\s+)'
    r'|(.)',
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = AppTypography.codeBody.copyWith(
      fontSize: 13,
      color: isDark ? AppColors.codeText : const Color(0xFF1F2937),
    );
    final commentColor = isDark ? AppColors.codeComment : const Color(0xFF6B7A99);
    final stringColor = isDark ? AppColors.codeString : const Color(0xFF059669);
    final numberColor = isDark ? AppColors.codeNumber : const Color(0xFFD97706);
    final keywordStyle = AppTypography.codeKeyword.copyWith(
      fontSize: 13,
      color: isDark ? AppColors.codeKeyword : const Color(0xFF7C3AED),
    );
    final spans = <TextSpan>[];
    for (final match in _tokenPattern.allMatches(text)) {
      final m = match.group(0)!;
      TextStyle ts;
      if (match.group(1) != null) {
        ts = base.copyWith(color: commentColor);
      } else if (match.group(2) != null) {
        ts = base.copyWith(color: stringColor);
      } else if (match.group(3) != null) {
        ts = base.copyWith(color: numberColor);
      } else if (match.group(4) != null && _keywords.contains(m)) {
        ts = keywordStyle;
      } else {
        ts = base;
      }
      spans.add(TextSpan(text: m, style: ts));
    }
    if (spans.isEmpty) spans.add(TextSpan(text: text, style: base));
    return TextSpan(children: spans, style: style);
  }
}

bool _listEquals(List<_Snippet> a, List<_Snippet> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!identical(a[i], b[i]) && a[i].trigger != b[i].trigger) return false;
  }
  return true;
}
