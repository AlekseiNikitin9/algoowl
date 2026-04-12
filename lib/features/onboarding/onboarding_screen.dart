import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/owl_button.dart';
import '../../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  // Selections
  String? _experienceLevel;
  int? _dailyGoal;
  bool _customGoalSelected = false;
  final _customGoalController = TextEditingController();
  String? _focus;
  String? _hearAboutUs;
  final _hearAboutUsOtherController = TextEditingController();
  ThemeMode _selectedThemeMode = ThemeMode.system;

  static const int _totalPages = 6;

  @override
  void dispose() {
    _controller.dispose();
    _customGoalController.dispose();
    _hearAboutUsOtherController.dispose();
    super.dispose();
  }

  void _next() {
    // Dismiss keyboard before transitioning to prevent overflow
    FocusScope.of(context).unfocus();
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
      );
    } else {
      _complete();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
      );
    }
  }

  Future<void> _complete() async {
    final notifier = ref.read(userProfileProvider.notifier);
    if (_experienceLevel != null) notifier.setExperienceLevel(_experienceLevel!);
    if (_dailyGoal != null) notifier.setDailyGoal(_dailyGoal!);
    if (_focus != null) notifier.setFocus(_focus!);
    if (_hearAboutUs != null) notifier.setHearAboutUs(_hearAboutUs!);

    // Persist preferences to backend (creates device account if needed)
    final api = ref.read(apiServiceProvider);
    try {
      await api.completeOnboarding(
        dailyGoalMinutes: _dailyGoal ?? 10,
        experienceLevel: _experienceLevel ?? 'beginner',
        focus: _focus ?? 'both',
      );
    } catch (_) {
      // Backend unavailable - continue in local-only mode
    }

    ref.read(onboardingCompleteProvider.notifier).state = true;
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true; // Welcome
      case 1:
        return _experienceLevel != null;
      case 2:
        if (_customGoalSelected) {
          final val = int.tryParse(_customGoalController.text.trim());
          return val != null && val > 0 && val <= 180;
        }
        return _dailyGoal != null;
      case 3:
        return _focus != null;
      case 4:
        if (_hearAboutUs == 'other') {
          return _hearAboutUsOtherController.text.trim().isNotEmpty;
        }
        return _hearAboutUs != null;
      case 5:
        return true; // Theme - always valid (pre-selected)
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space4),
            // ── Top bar: back arrow + dots ───────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Row(
                children: [
                  // Back arrow (hidden on welcome page)
                  SizedBox(
                    width: 36,
                    child: _currentPage > 0
                        ? GestureDetector(
                            onTap: _back,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _controller,
                        count: _totalPages,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: AppColors.primary,
                          dotColor: cs.outline,
                          spacing: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // balance
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcome(),
                  _buildExperienceLevel(),
                  _buildDailyGoal(),
                  _buildFocus(),
                  _buildHearAboutUs(),
                  _buildThemeSelection(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.space4,
              ),
              child: OwlButton(
                label: _currentPage < _totalPages - 1 ? 'Continue' : 'Get Started',
                onPressed: _canProceed ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Welcome ─────────────────────────────────────────────────
  Widget _buildWelcome() {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.code, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text('Welcome to Codekata', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Master DSA and crush your coding interviews - one bite-sized lesson at a time.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Experience ───────────────────────────────────────────────
  Widget _buildExperienceLevel() {
    return _buildSelectionPage(
      title: "What's your experience?",
      subtitle: "We'll personalize your learning path.",
      options: [
        ('beginner', 'Beginner', 'New to coding or DSA'),
        ('intermediate', 'Intermediate', 'Know basics, building skills'),
        ('advanced', 'Advanced', 'Prepping for FAANG interviews'),
      ],
      selected: _experienceLevel,
      onSelect: (v) => setState(() => _experienceLevel = v),
    );
  }

  // ── Daily Goal ───────────────────────────────────────────────
  Widget _buildDailyGoal() {
    final cs = Theme.of(context).colorScheme;
    final options = [
      ('5', '5 min', 'Quick review'),
      ('10', '10 min', 'Steady progress'),
      ('20', '20 min', 'Serious grind'),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space12),
            Text('Set your daily goal', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'How many minutes do you want to grind each day?',
              style: AppTypography.body.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.space8),
            // Preset options
            ...options.map((opt) {
              final isSelected = !_customGoalSelected && _dailyGoal?.toString() == opt.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: _OptionTile(
                  label: opt.$2,
                  description: opt.$3,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _dailyGoal = int.parse(opt.$1);
                      _customGoalSelected = false;
                    });
                  },
                ),
              );
            }),
            // Custom option
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _customGoalSelected = true;
                    _dailyGoal = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: _customGoalSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : cs.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _customGoalSelected
                          ? AppColors.primary
                          : cs.outline,
                      width: _customGoalSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Custom', style: AppTypography.bodyLg),
                                const SizedBox(height: 2),
                                Text(
                                  'Enter your own goal',
                                  style: AppTypography.caption.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_customGoalSelected)
                            const Icon(Icons.check_circle,
                                color: AppColors.primary, size: 24),
                        ],
                      ),
                      if (_customGoalSelected) ...[
                        const SizedBox(height: AppSpacing.space3),
                        TextField(
                          controller: _customGoalController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'e.g. 15',
                            suffixText: 'min',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (v) {
                            final val = int.tryParse(v.trim());
                            if (val != null && val > 0) {
                              setState(() => _dailyGoal = val);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Focus ────────────────────────────────────────────────────
  Widget _buildFocus() {
    return _buildSelectionPage(
      title: "What's your goal?",
      subtitle: 'This helps us pick the right content.',
      options: [
        ('interview', 'Interview Prep', 'Get job-ready fast'),
        ('learn', 'Learn DSA', 'Deep understanding'),
        ('both', 'Both', 'All of the above'),
      ],
      selected: _focus,
      onSelect: (v) => setState(() => _focus = v),
    );
  }

  // ── Hear About Us ────────────────────────────────────────────
  Widget _buildHearAboutUs() {
    final cs = Theme.of(context).colorScheme;
    final options = [
      ('tiktok', 'TikTok'),
      ('instagram', 'Instagram'),
      ('linkedin', 'LinkedIn'),
      ('twitter', 'Twitter / X'),
      ('youtube', 'YouTube'),
      ('school', 'School / University'),
      ('friend', 'Friend or colleague'),
      ('other', 'Other'),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.space12),
            Text('Where did you hear about us?', style: AppTypography.h1),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Help us understand how you found Codekata.',
              style: AppTypography.body.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.space8),
            ...options.map((opt) {
              final isSelected = _hearAboutUs == opt.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _hearAboutUs = opt.$1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : cs.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : cs.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(opt.$2, style: AppTypography.bodyLg),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 24),
                          ],
                        ),
                        if (isSelected && opt.$1 == 'other') ...[
                          const SizedBox(height: AppSpacing.space3),
                          TextField(
                            controller: _hearAboutUsOtherController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Tell us more...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide(color: cs.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                borderSide:
                                    const BorderSide(color: AppColors.primary),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.space4),
          ],
        ),
      ),
    );
  }

  // ── Theme Selection ──────────────────────────────────────────
  Widget _buildThemeSelection() {
    final cs = Theme.of(context).colorScheme;
    final options = [
      (ThemeMode.light, Icons.light_mode, 'Light', 'Clean and bright'),
      (ThemeMode.dark, Icons.dark_mode, 'Dark', 'Easy on the eyes'),
      (ThemeMode.system, Icons.phone_android, 'System', 'Match your device'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space12),
          Text('Choose your theme', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Pick your preferred look.',
            style: AppTypography.body.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.space8),
          ...options.map((opt) {
            final isSelected = _selectedThemeMode == opt.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedThemeMode = opt.$1);
                  ref.read(themeModeProvider.notifier).state = opt.$1;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : cs.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : cs.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(opt.$2, color: isSelected ? AppColors.primary : cs.onSurfaceVariant, size: 24),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.$3, style: AppTypography.bodyLg),
                            const SizedBox(height: 2),
                            Text(
                              opt.$4,
                              style: AppTypography.caption.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
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
          const SizedBox(height: AppSpacing.space3),
          Text(
            'You can change this later in your profile.',
            style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Shared selection page ────────────────────────────────────
  Widget _buildSelectionPage({
    required String title,
    required String subtitle,
    required List<(String value, String label, String description)> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space12),
          Text(title, style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space2),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.space8),
          ...options.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: _OptionTile(
                label: opt.$2,
                description: opt.$3,
                isSelected: selected == opt.$1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(opt.$1);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : cs.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyLg),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
