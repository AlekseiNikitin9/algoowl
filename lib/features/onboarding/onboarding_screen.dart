import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/ck_icons.dart';
import '../../core/widgets/owl_button.dart';
import '../../core/widgets/theme_toggle.dart';
import '../../core/services/api_service.dart';
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
    'welcome', 'experience', 'goal', 'focus', 'hear', 'save', 'theme', 'finish',
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
      case 'finish':
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
    if (_stepName == 'finish') return 'Enter Codekata';
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
              onSkip: (_step > 0 && _step < _total - 1) ? _complete : null,
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
      case 'finish':
        return const _FinishStep();
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
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        const SizedBox(height: 28),
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.32),
                offset: const Offset(0, 20),
                blurRadius: 44,
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/icons/codekata-logo-c.svg',
            width: 108,
            height: 108,
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

    final Widget ck = switch (icon) {
      _FeatureIcon.bolt => const CkIcon.bolt(size: 17, color: AppColors.primaryDark),
      _FeatureIcon.flame => const Icon(Icons.local_fire_department_rounded, size: 17, color: AppColors.primaryDark),
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
class _SaveStep extends ConsumerStatefulWidget {
  final String? value;
  final ValueChanged<String> onChange;

  const _SaveStep({required this.value, required this.onChange});

  @override
  ConsumerState<_SaveStep> createState() => _SaveStepState();
}

class _SaveStepState extends ConsumerState<_SaveStep> {
  String? _loading; // 'apple' | 'google' | 'email' | null
  bool _showEmailForm = false;
  bool _isSignIn = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _authWithProvider(String provider) async {
    final api = ref.read(apiServiceProvider);
    setState(() => _loading = provider);
    try {
      final bool authenticated;
      if (provider == 'google') {
        authenticated = await api.loginWithGoogle();
      } else {
        authenticated = await api.loginWithApple();
      }
      if (!authenticated) return; // user cancelled
      await _handlePostAuth(provider);
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError('Sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _submitEmailForm() async {
    final api = ref.read(apiServiceProvider);
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }
    setState(() => _loading = 'email');
    try {
      if (_isSignIn) {
        await api.login(email: email, password: pass);
      } else {
        await api.register(
          email: email,
          password: pass,
          name: email.split('@').first,
        );
      }
      await _handlePostAuth('email');
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.statusCode == 409
            ? 'Email already exists — try signing in instead.'
            : e.statusCode == 401
                ? 'Incorrect email or password.'
                : e.message);
      }
    } catch (e) {
      if (mounted) _showError('Sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  Future<void> _handlePostAuth(String provider) async {
    final api = ref.read(apiServiceProvider);
    try {
      final me = await api.getMe();
      await ref.read(userProfileProvider.notifier).loadFromApi(api);
      if (me['onboarding_complete'] == true) {
        // Returning user — skip straight to home
        ref.read(onboardingCompleteProvider.notifier).state = true;
        return;
      }
    } catch (_) {}
    widget.onChange(provider);
    if (provider == 'email' && mounted) setState(() => _showEmailForm = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextSecondary : AppColors.textDisabled;

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
          iconWidget: const FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 17),
          bg: Colors.black,
          fg: Colors.white,
          selected: widget.value == 'apple',
          loading: _loading == 'apple',
          onTap: _loading != null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  _authWithProvider('apple');
                },
        ),
        const SizedBox(height: 10),
        _ProviderButton(
          label: 'Continue with Google',
          iconWidget: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 16,
            height: 16,
          ),
          bg: isDark ? AppColors.darkSurfaceAlt : Colors.white,
          fg: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          bordered: true,
          selected: widget.value == 'google',
          loading: _loading == 'google',
          onTap: _loading != null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  _authWithProvider('google');
                },
        ),
        const SizedBox(height: 10),
        _ProviderButton(
          label: 'Use email',
          iconWidget: FaIcon(
            FontAwesomeIcons.envelope,
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            size: 14,
          ),
          bg: isDark
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.primarySurface,
          fg: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          selected: widget.value == 'email',
          loading: _loading == 'email' && !_showEmailForm,
          onTap: _loading != null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  setState(() => _showEmailForm = !_showEmailForm);
                },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: _showEmailForm
              ? _EmailForm(
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  isSignIn: _isSignIn,
                  loading: _loading == 'email',
                  onToggleMode: () => setState(() => _isSignIn = !_isSignIn),
                  onSubmit: _submitEmailForm,
                )
              : const SizedBox.shrink(),
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

class _EmailForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool isSignIn;
  final bool loading;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;

  const _EmailForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.isSignIn,
    required this.loading,
    required this.onToggleMode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    InputDecoration fieldDecoration(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body.copyWith(color: textSecondary, fontSize: 14),
          filled: true,
          fillColor: surfaceBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: AppTypography.body.copyWith(fontSize: 14),
            decoration: fieldDecoration('Email address'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passCtrl,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            style: AppTypography.body.copyWith(fontSize: 14),
            decoration: fieldDecoration('Password'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: loading ? null : onSubmit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isSignIn ? 'Sign In' : 'Create Account',
                            style: AppTypography.bodyLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onToggleMode,
                child: Text(
                  isSignIn ? 'New here?' : 'Have an account?',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final Color bg;
  final Color fg;
  final bool selected;
  final bool bordered;
  final bool loading;
  final VoidCallback? onTap;

  const _ProviderButton({
    required this.label,
    required this.iconWidget,
    required this.bg,
    required this.fg,
    required this.selected,
    required this.onTap,
    this.bordered = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final chipBg = bordered
        ? (isDark ? AppColors.darkSurfaceAlt : Colors.white)
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
              child: loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: fg,
                      ),
                    )
                  : iconWidget,
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
            if (selected && !loading) CkIcon.check(size: 18, color: fg),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALMOST THERE',
          style: AppTypography.eyebrow.copyWith(color: textSecondary),
        ),
        const SizedBox(height: 8),
        Text('Pick a theme', style: AppTypography.h1),
        const SizedBox(height: 8),
        Text(
          'You can change this anytime in settings.',
          style: AppTypography.caption.copyWith(color: textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 28),
        ThemeToggle(value: value, onChange: onChange),
      ],
    );
  }
}

// ── Finish step ───────────────────────────────────────────────
class _FinishStep extends StatelessWidget {
  const _FinishStep();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final screenH = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.paddingOf(context).top;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: screenH - topPad - 180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CkIcon.check(size: 44, color: AppColors.successDark),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "You're all set!",
            style: AppTypography.display.copyWith(fontSize: 34, height: 1.1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.body.copyWith(
                  color: textSecondary,
                  fontSize: 15,
                  height: 1.55,
                ),
                children: [
                  const TextSpan(text: 'Your first lesson is ready — '),
                  TextSpan(
                    text: 'Two Sum',
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const TextSpan(text: '\nEst. 8 min · +20 XP'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

