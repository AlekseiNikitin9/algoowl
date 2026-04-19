import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chapter_glyph.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/owl_button.dart';
import '../../providers/app_providers.dart';

/// 7-step onboarding flow:
///   0 welcome · 1 experience · 2 goal · 3 focus · 4 hear · 5 save · 6 theme
/// Mirrors codekata_redesign/src/onboarding.jsx exactly.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<String> _steps = [
    'welcome', 'experience', 'goal', 'focus', 'hear', 'save', 'theme',
  ];

  int _step = 0;

  String? _experience;
  int? _goal;
  final _customGoalController = TextEditingController();
  String? _focus;
  String? _hear;
  String? _save;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void dispose() {
    _customGoalController.dispose();
    super.dispose();
  }

  String get _stepName => _steps[_step];
  int get _total => _steps.length;

  bool get _canContinue {
    switch (_stepName) {
      case 'welcome':
        return true;
      case 'experience':
        return _experience != null;
      case 'goal':
        if (_goal != null) return true;
        final n = int.tryParse(_customGoalController.text.trim());
        return n != null && n > 0 && n <= 180;
      case 'focus':
        return _focus != null;
      case 'hear':
        return _hear != null;
      case 'save':
        return true; // soft-gate
      case 'theme':
        return true;
      default:
        return true;
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    if (_step == _total - 1) {
      _complete();
    } else {
      setState(() => _step += 1);
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) return;
    setState(() => _step -= 1);
  }

  Future<void> _complete() async {
    final notifier = ref.read(userProfileProvider.notifier);
    if (_experience != null) notifier.setExperienceLevel(_experience!);
    final goal = _goal ?? int.tryParse(_customGoalController.text.trim()) ?? 10;
    notifier.setDailyGoal(goal);
    if (_focus != null) notifier.setFocus(_focus!);
    if (_hear != null) notifier.setHearAboutUs(_hear!);

    final api = ref.read(apiServiceProvider);
    try {
      await api.completeOnboarding(
        dailyGoalMinutes: goal,
        experienceLevel: _experience ?? 'beginner',
        focus: _focus ?? 'both',
      );
    } catch (_) {/* backend unavailable — local-only */}

    ref.read(onboardingCompleteProvider.notifier).state = true;
  }

  String get _ctaLabel {
    if (_stepName == 'welcome') return 'Get started';
    if (_stepName == 'theme') return 'Enter Codekata';
    if (_stepName == 'save' && _save == null) return 'Maybe later';
    return 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              step: _step,
              total: _total,
              onBack: _step > 0 ? _back : null,
              onSkip: _step > 0 ? _complete : null,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: _body(),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16, 12, 16,
                MediaQuery.paddingOf(context).bottom + 20,
              ),
              child: OwlButton(
                label: _ctaLabel,
                onPressed: _canContinue ? _next : null,
                leading: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_stepName) {
      case 'welcome':
        return const _WelcomeStep();
      case 'experience':
        return _PickList(
          eyebrow: 'About you',
          title: 'How much have you coded before?',
          options: const [
            _PickOpt('none', 'Brand new', "I haven't written code"),
            _PickOpt('beginner', 'Beginner', 'Dabbled in a language or two'),
            _PickOpt('junior', 'Junior dev', '< 2 years of production code'),
            _PickOpt('mid', 'Mid / Senior', 'Comfortable, rusty on DSA'),
          ],
          value: _experience,
          onChange: (v) => setState(() => _experience = v),
        );
      case 'goal':
        return _GoalStep(
          value: _goal,
          customController: _customGoalController,
          onChange: (v) => setState(() => _goal = v),
        );
      case 'focus':
        return _PickList(
          eyebrow: 'Your focus',
          title: "What are you training for?",
          options: const [
            _PickOpt('interview', 'Tech interviews', 'FAANG, startups, promotions'),
            _PickOpt('learn', 'Genuinely learning DSA', 'Fill the CS gap'),
            _PickOpt('both', 'Both, honestly', 'Best of both worlds'),
          ],
          value: _focus,
          onChange: (v) => setState(() => _focus = v),
        );
      case 'hear':
        return _PickList(
          eyebrow: 'One last thing',
          title: 'How did you hear about Codekata?',
          options: const [
            _PickOpt('tiktok', 'TikTok / Reels', 'Social video'),
            _PickOpt('friend', 'Friend or colleague', 'Word of mouth'),
            _PickOpt('search', 'Search engine', 'Google, DuckDuckGo…'),
            _PickOpt('store', 'App store', 'Browsing / featured'),
            _PickOpt('other', 'Somewhere else', 'Blog, newsletter, etc.'),
          ],
          value: _hear,
          onChange: (v) => setState(() => _hear = v),
        );
      case 'save':
        return _SaveStep(
          value: _save,
          onChange: (v) => setState(() => _save = v),
        );
      case 'theme':
        return _ThemeStep(
          value: _themeMode,
          onChange: (v) {
            setState(() => _themeMode = v);
            ref.read(themeModeProvider.notifier).state = v;
          },
        );
    }
    return const SizedBox.shrink();
  }
}

// ── Top bar ───────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const _TopBar({
    required this.step,
    required this.total,
    this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final progress = (step + 1) / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          _CircleBtn(
            icon: const CkIcon.chevL(size: 18, color: AppColors.textSecondary),
            onTap: onBack,
            visible: onBack != null,
          ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: surfaceAlt,
                  border: Border.all(color: border, width: 1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (_, c) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuart,
                      width: c.maxWidth * progress,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onSkip != null) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSkip,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  'Skip',
                  style: AppTypography.label.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final bool visible;

  const _CircleBtn({required this.icon, this.onTap, this.visible = true});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

// ── Welcome step ──────────────────────────────────────────────
class _WelcomeStep extends StatefulWidget {
  const _WelcomeStep();

  @override
  State<_WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<_WelcomeStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        const SizedBox(height: 28),
        SizedBox(
          width: 104,
          height: 104,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.28),
                        offset: const Offset(0, 20),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: CustomPaint(
                      painter: _WelcomeShimmer(_c.value),
                    ),
                  ),
                ),
                CustomPaint(
                  size: const Size(52, 52),
                  painter: _MonoGlyph(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'WELCOME TO',
          style: AppTypography.eyebrow.copyWith(
            color: AppColors.primaryDark,
            letterSpacing: 0.16 * 11,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Codekata',
          style: AppTypography.display.copyWith(fontSize: 42, height: 1),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Learn data structures & algorithms the way you'd practice an instrument — one small, focused rep at a time.",
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: textSecondary, height: 1.55),
          ),
        ),
        const SizedBox(height: 32),
        const _WelcomeFeature(
          icon: _FeatureIcon.bolt,
          title: 'Bite-sized lessons',
          subtitle: '10 minutes a day is enough',
        ),
        const SizedBox(height: 10),
        const _WelcomeFeature(
          icon: _FeatureIcon.flame,
          title: 'Streaks that stick',
          subtitle: 'Show up, not show off',
        ),
        const SizedBox(height: 10),
        const _WelcomeFeature(
          icon: _FeatureIcon.check,
          title: 'Think, then type',
          subtitle: "We'll nudge you to the approach",
        ),
      ],
    );
  }
}

class _WelcomeShimmer extends CustomPainter {
  final double t;
  _WelcomeShimmer(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.longestSide;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = SweepGradient(
      transform: GradientRotation(t * 2 * 3.141592653589793),
      colors: [
        const Color(0x00FFFFFF),
        Colors.white.withValues(alpha: 0.22),
        const Color(0x00FFFFFF),
        const Color(0xFFC8E4FF).withValues(alpha: 0.25),
        const Color(0x00FFFFFF),
      ],
      stops: const [0.0, 0.15, 0.4, 0.55, 0.85],
    ).createShader(rect);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = shader
        ..blendMode = BlendMode.overlay,
    );
  }

  @override
  bool shouldRepaint(_WelcomeShimmer old) => old.t != t;
}

class _MonoGlyph extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 52;
    canvas.save();
    canvas.scale(scale);
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final p = Path()
      ..moveTo(10, 26)
      ..lineTo(16, 20)
      ..lineTo(22, 26)
      ..lineTo(28, 20)
      ..lineTo(42, 34);
    canvas.drawPath(p, stroke);
    canvas.drawCircle(
      const Offset(40, 16),
      3,
      Paint()..color = Colors.white,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MonoGlyph old) => false;
}

enum _FeatureIcon { bolt, flame, check }

class _WelcomeFeature extends StatelessWidget {
  final _FeatureIcon icon;
  final String title;
  final String subtitle;

  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final tileBg = isDark
        ? AppColors.primary.withValues(alpha: 0.14)
        : AppColors.primarySurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final CkIcon ck = switch (icon) {
      _FeatureIcon.bolt => const CkIcon.bolt(size: 17, color: AppColors.primaryDark),
      _FeatureIcon.flame => const CkIcon.flame(size: 17, color: AppColors.primaryDark),
      _FeatureIcon.check => const CkIcon.check(size: 17, color: AppColors.primaryDark),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: ck,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pick list (radio) ─────────────────────────────────────────
class _PickOpt {
  final String key;
  final String label;
  final String sub;
  const _PickOpt(this.key, this.label, this.sub);
}

class _PickList extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<_PickOpt> options;
  final String? value;
  final ValueChanged<String> onChange;

  const _PickList({
    required this.eyebrow,
    required this.title,
    required this.options,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppTypography.eyebrow.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Text(title, style: AppTypography.h1),
        const SizedBox(height: 18),
        for (var i = 0; i < options.length; i++) ...[
          _OptTile(
            selected: value == options[i].key,
            onTap: () {
              HapticFeedback.selectionClick();
              onChange(options[i].key);
            },
            leading: _RadioDot(selected: value == options[i].key),
            title: options[i].label,
            subtitle: options[i].sub,
          ),
          if (i != options.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.borderStrong);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

class _OptTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;

  const _OptTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primarySurface)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Goal step (with custom input) ─────────────────────────────
class _GoalStep extends StatefulWidget {
  final int? value;
  final TextEditingController customController;
  final ValueChanged<int?> onChange;

  const _GoalStep({
    required this.value,
    required this.customController,
    required this.onChange,
  });

  @override
  State<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends State<_GoalStep> {
  static const List<_GoalOpt> _opts = [
    _GoalOpt(5, 'Casual', '5 min · 1 problem'),
    _GoalOpt(10, 'Regular', '10 min · 2 problems', recommended: true),
    _GoalOpt(20, 'Serious', '20 min · 4 problems'),
    _GoalOpt(30, 'Insane', '30 min · 6 problems'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final customActive = widget.value == null &&
        widget.customController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY GOAL',
          style: AppTypography.eyebrow.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Text('How much a day sounds right?', style: AppTypography.h1),
        const SizedBox(height: 4),
        Text(
          'You can change this anytime in settings.',
          style: AppTypography.caption.copyWith(color: textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < _opts.length; i++) ...[
          _GoalTile(
            opt: _opts[i],
            selected: widget.value == _opts[i].minutes,
            onTap: () {
              HapticFeedback.selectionClick();
              widget.customController.clear();
              widget.onChange(_opts[i].minutes);
            },
          ),
          const SizedBox(height: 10),
        ],
        // Custom
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: customActive
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.primarySurface)
                : surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: customActive ? AppColors.primary : border,
              width: customActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: customActive ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: customActive
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.borderStrong),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: customActive
                        ? const CkIcon.check(size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Custom',
                    style: AppTypography.label.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Row(
                  children: [
                    SizedBox(
                      width: 78,
                      child: TextField(
                        controller: widget.customController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.codeBody.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: '15',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8,
                          ),
                          filled: true,
                          fillColor: surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onChanged: (v) {
                          widget.onChange(null);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'minutes',
                      style: AppTypography.caption.copyWith(color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalOpt {
  final int minutes;
  final String label;
  final String sub;
  final bool recommended;
  const _GoalOpt(this.minutes, this.label, this.sub, {this.recommended = false});
}

class _GoalTile extends StatelessWidget {
  final _GoalOpt opt;
  final bool selected;
  final VoidCallback onTap;

  const _GoalTile({
    required this.opt,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primarySurface)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                '${opt.minutes}',
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  fontSize: 22,
                  height: 1,
                  color: selected ? AppColors.primaryDark : textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        opt.label,
                        style: AppTypography.label.copyWith(fontSize: 15),
                      ),
                      if (opt.recommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'RECOMMENDED',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.successDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.08 * 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    opt.sub,
                    style: AppTypography.caption.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Save progress step (Apple / Google / email) ───────────────
class _SaveStep extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChange;

  const _SaveStep({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextSecondary : AppColors.textDisabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SAVE YOUR PROGRESS',
          style: AppTypography.eyebrow.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          "Don't lose your streak if you switch phones",
          style: AppTypography.h1,
        ),
        const SizedBox(height: 4),
        Text(
          "Optional — you can skip and we'll keep progress on this device. Sign in anytime from your profile.",
          style: AppTypography.body.copyWith(
            color: textSecondary,
            fontSize: 13,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),
        _ProviderButton(
          label: 'Continue with Apple',
          glyph: 'A',
          bg: Colors.black,
          fg: Colors.white,
          selected: value == 'apple',
          onTap: () {
            HapticFeedback.selectionClick();
            onChange('apple');
          },
        ),
        const SizedBox(height: 10),
        _ProviderButton(
          label: 'Continue with Google',
          glyph: 'G',
          bg: Colors.white,
          fg: const Color(0xFF1A1F2E),
          bordered: true,
          selected: value == 'google',
          onTap: () {
            HapticFeedback.selectionClick();
            onChange('google');
          },
        ),
        const SizedBox(height: 10),
        _ProviderButton(
          label: 'Use email',
          glyph: '@',
          bg: isDark
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.primarySurface,
          fg: AppColors.primaryDark,
          selected: value == 'email',
          onTap: () {
            HapticFeedback.selectionClick();
            onChange('email');
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'By signing in you agree to Terms & Privacy.',
            style: AppTypography.caption.copyWith(
              color: textTertiary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final String label;
  final String glyph;
  final Color bg;
  final Color fg;
  final bool selected;
  final bool bordered;
  final VoidCallback onTap;

  const _ProviderButton({
    required this.label,
    required this.glyph,
    required this.bg,
    required this.fg,
    required this.selected,
    required this.onTap,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final chipBg = bordered
        ? (isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt)
        : Colors.white.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (bordered ? border : Colors.transparent),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.18 : 0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Text(
                glyph,
                style: AppTypography.h3.copyWith(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (selected) CkIcon.check(size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

// ── Theme step ────────────────────────────────────────────────
class _ThemeStep extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChange;

  const _ThemeStep({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ONE LAST THING',
          style: AppTypography.eyebrow.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Text('Pick a theme', style: AppTypography.h1),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ThemeTile(
                label: 'Light',
                mode: ThemeMode.light,
                selected: value == ThemeMode.light,
                onTap: () => onChange(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeTile(
                label: 'Dark',
                mode: ThemeMode.dark,
                selected: value == ThemeMode.dark,
                onTap: () => onChange(ThemeMode.dark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeTile(
                label: 'System',
                mode: ThemeMode.system,
                selected: value == ThemeMode.system,
                onTap: () => onChange(ThemeMode.system),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              const ChapterGlyph(kind: GlyphKind.hash, size: 48),
              const SizedBox(height: 10),
              Text(
                "You're all set",
                style: AppTypography.h2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.caption.copyWith(
                    color: textSecondary, fontSize: 13,
                  ),
                  children: [
                    const TextSpan(text: 'First lesson: '),
                    TextSpan(
                      text: 'Two Sum',
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const TextSpan(text: ' · 8 min'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final preview = switch (mode) {
      ThemeMode.light => const _ThemePreview(light: true),
      ThemeMode.dark => const _ThemePreview(light: false),
      ThemeMode.system => const _ThemePreviewSystem(),
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primarySurface)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              clipBehavior: Clip.antiAlias,
              child: preview,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 13,
                color: selected ? AppColors.primaryDark : textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final bool light;
  const _ThemePreview({required this.light});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: light ? Colors.white : const Color(0xFF1A1F2E),
      alignment: Alignment.center,
      child: light
          ? const CkIcon.sun(size: 22, color: AppColors.textPrimary)
          : const CkIcon.moon(size: 22, color: Colors.white),
    );
  }
}

class _ThemePreviewSystem extends StatelessWidget {
  const _ThemePreviewSystem();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SystemPreviewPainter(),
    );
  }
}

class _SystemPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width / 2, size.height),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
      Paint()..color = const Color(0xFF1A1F2E),
    );
  }

  @override
  bool shouldRepaint(_SystemPreviewPainter old) => false;
}
