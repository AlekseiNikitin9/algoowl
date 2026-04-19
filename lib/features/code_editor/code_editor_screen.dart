import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
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
  late _SyntaxController _code;
  late FocusNode _focus;

  String _lang = 'python';
  bool _showHint = false;
  bool _running = false;
  String? _status; // 'passed' | 'failed' | null
  int? _passed;
  int? _total;
  String? _errorMsg;
  List<_Snippet> _suggestions = const [];
  bool _showDust = false;

  List<_Snippet> get _activeSnippets =>
      _lang == 'python' ? _pythonSnippets : _jsSnippets;

  @override
  void initState() {
    super.initState();
    final problems = ref.read(problemsProvider);
    _problem = problems.firstWhere(
      (p) => p.slug == widget.problemSlug,
      orElse: () => problems.first,
    );
    _code = _SyntaxController(_lang);
    _code.text = _problem.starterCode[_lang] ?? 'def solve():\n    pass';
    _code.addListener(_onCodeChanged);
    _focus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _code.removeListener(_onCodeChanged);
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _currentWord {
    final sel = _code.selection;
    if (!sel.isValid || !sel.isCollapsed) return '';
    final text = _code.text;
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
      setState(() => _suggestions = next);
    }
  }

  void _switchLang(String lang) {
    if (_lang == lang) return;
    HapticFeedback.selectionClick();
    setState(() {
      _lang = lang;
      _code.setLanguage(lang);
      _code.text = _problem.starterCode[lang] ??
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
    final sel = _code.selection;
    if (!sel.isValid) return;
    final text = _code.text;
    final cursor = sel.baseOffset;
    final start = cursor - word.length;
    final newText = text.replaceRange(start, cursor, s.template);
    final newCursor = start + s.template.length - s.cursorFromEnd;
    _code.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: newCursor.clamp(0, newText.length)),
    );
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    _focus.unfocus();
    setState(() => _running = true);

    final api = ref.read(apiServiceProvider);
    Map<String, dynamic> result;
    try {
      result = await api.submitCode(
        problemSlug: _problem.slug,
        language: _lang,
        code: _code.text,
      );
    } on ApiException catch (e) {
      result = {
        'status': 'runtime_error',
        'test_cases_passed': 0,
        'test_cases_total': 0,
        'error': e.message,
      };
    } catch (e) {
      result = {
        'status': 'runtime_error',
        'test_cases_passed': 0,
        'test_cases_total': 0,
        'error': e.toString(),
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
    }
  }

  void _openResults() {
    context.push('/accepted/${_problem.slug}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.codeBg,
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
                  controller: _code,
                  focus: _focus,
                )),
                if (_suggestions.isNotEmpty && _status == null)
                  _SuggestionBar(
                    suggestions: _suggestions,
                    onTap: _insertSnippet,
                  ),
                if (_status == 'failed') _FailureBanner(
                  passed: _passed,
                  total: _total,
                  message: _errorMsg,
                ),
                _SubmitBar(
                  status: _status,
                  running: _running,
                  onSubmit: _submit,
                  onViewResults: _openResults,
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
    final eyebrowColor = Colors.white.withValues(alpha: 0.45);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          _SquareBtn(
            icon: CkIcon.close(
              size: 17,
              color: Colors.white.withValues(alpha: 0.75),
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
                    color: Colors.white,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langBtn('python', 'Py'),
          _langBtn('javascript', 'JS'),
        ],
      ),
    );
  }

  Widget _langBtn(String key, String label) {
    final active = lang == key;
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
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.55),
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

class _PromptStrip extends StatelessWidget {
  final Problem problem;
  final bool showHint;
  final VoidCallback onToggleHint;

  const _PromptStrip({
    required this.problem,
    required this.showHint,
    required this.onToggleHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              problem.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleHint();
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: showHint
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: showHint
                      ? AppColors.gold.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CkIcon.hint(
                    size: 13,
                    color: showHint
                        ? AppColors.gold
                        : Colors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hint',
                    style: AppTypography.caption.copyWith(
                      color: showHint
                          ? AppColors.gold
                          : Colors.white.withValues(alpha: 0.75),
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
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String text;
  const _HintBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          color: Colors.white.withValues(alpha: 0.85),
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

  const _CodeCanvas({required this.controller, required this.focus});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focus.requestFocus(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Gutter(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                child: TextField(
                  controller: controller,
                  focusNode: focus,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: AppTypography.codeBody.copyWith(fontSize: 13),
                  cursorColor: Colors.white,
                  cursorWidth: 2,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Gutter extends StatelessWidget {
  final TextEditingController controller;
  const _Gutter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final lines = controller.text.split('\n').length;
        return Container(
          width: 38,
          color: AppColors.codeBgAlt,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              lines,
              (i) => SizedBox(
                height: 20,
                child: Text(
                  '${i + 1}',
                  style: AppTypography.codeBody.copyWith(
                    color: Colors.white.withValues(alpha: 0.25),
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
// Suggestion chips (accessory bar)
// ═══════════════════════════════════════════════════════════════

class _SuggestionBar extends StatelessWidget {
  final List<_Snippet> suggestions;
  final ValueChanged<_Snippet> onTap;

  const _SuggestionBar({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.codeBgAlt,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final s = suggestions[i];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap(s);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                s.label,
                style: AppTypography.codeBody.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
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

class _SubmitBar extends StatelessWidget {
  final String? status;
  final bool running;
  final VoidCallback onSubmit;
  final VoidCallback onViewResults;

  const _SubmitBar({
    required this.status,
    required this.running,
    required this.onSubmit,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final isPassed = status == 'passed';
    final isFailed = status == 'failed';

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + bottomPad),
      decoration: BoxDecoration(
        color: AppColors.codeBg,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: isPassed
                ? OwlButton.success(
                    label: 'View Results',
                    onPressed: onViewResults,
                    leading: const CkIcon.chevR(size: 18, color: Colors.white),
                  )
                : OwlButton(
                    label: running
                        ? 'Running…'
                        : isFailed
                            ? 'Try Again'
                            : 'Run & Submit',
                    isLoading: running,
                    onPressed: running ? null : onSubmit,
                    leading: running
                        ? null
                        : const CkIcon.run(size: 16, color: Colors.white),
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

bool _listEquals(List<_Snippet> a, List<_Snippet> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!identical(a[i], b[i]) && a[i].trigger != b[i].trigger) return false;
  }
  return true;
}
