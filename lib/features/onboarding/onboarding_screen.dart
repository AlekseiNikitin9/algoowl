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

  // Onboarding selections
  String? _experienceLevel;
  int? _dailyGoal;
  String? _focus;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
      );
    } else {
      // Complete onboarding
      final notifier = ref.read(userProfileProvider.notifier);
      if (_experienceLevel != null) {
        notifier.setExperienceLevel(_experienceLevel!);
      }
      if (_dailyGoal != null) notifier.setDailyGoal(_dailyGoal!);
      if (_focus != null) notifier.setFocus(_focus!);
      ref.read(onboardingCompleteProvider.notifier).state = true;
    }
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true; // Welcome screen
      case 1:
        return _experienceLevel != null;
      case 2:
        return _dailyGoal != null;
      case 3:
        return _focus != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space4),
            // Progress dots
            SmoothPageIndicator(
              controller: _controller,
              count: 4,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.border,
                spacing: 8,
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
                label: _currentPage < 3 ? 'Continue' : 'Get Started',
                onPressed: _canProceed ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Owl icon placeholder
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text('Welcome to AlgoOwl', style: AppTypography.h1),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'Master DSA and crush your coding interviews — one bite-sized lesson at a time.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceLevel() {
    return _buildSelectionPage(
      title: 'What\'s your experience?',
      subtitle: 'We\'ll personalize your learning path.',
      options: [
        ('beginner', 'Beginner', 'New to coding or DSA'),
        ('intermediate', 'Intermediate', 'Know basics, building skills'),
        ('advanced', 'Advanced', 'Prepping for FAANG interviews'),
      ],
      selected: _experienceLevel,
      onSelect: (v) => setState(() => _experienceLevel = v),
    );
  }

  Widget _buildDailyGoal() {
    return _buildSelectionPage(
      title: 'Set your daily goal',
      subtitle: 'You can change this anytime.',
      options: [
        ('5', '5 min', 'Quick review'),
        ('10', '10 min', 'Steady progress'),
        ('20', '20 min', 'Serious grind'),
      ],
      selected: _dailyGoal?.toString(),
      onSelect: (v) => setState(() => _dailyGoal = int.parse(v)),
    );
  }

  Widget _buildFocus() {
    return _buildSelectionPage(
      title: 'What\'s your goal?',
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

  Widget _buildSelectionPage({
    required String title,
    required String subtitle,
    required List<(String value, String label, String description)> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
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
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space8),
          ...options.map((opt) {
            final isSelected = selected == opt.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space3),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(opt.$1);
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
                      color:
                          isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.$2, style: AppTypography.bodyLg),
                            const SizedBox(height: 2),
                            Text(
                              opt.$3,
                              style: AppTypography.caption,
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
        ],
      ),
    );
  }
}
