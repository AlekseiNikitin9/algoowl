import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/api_service.dart';
import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/problem.dart';

/// Singleton API service - overridden in main.dart with the initialized instance.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Whether onboarding has been completed.
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// App theme mode (light / dark / system).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Current user profile.
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(const UserProfile(
          id: 'local-user',
          name: 'Learner',
          xp: 0,
          streak: 0,
        ));

  // ignore: use_super_parameters
  UserProfileNotifier.withProfile(UserProfile profile) : super(profile);

  Future<void> loadFromApi(ApiService api) async {
    try {
      final results = await Future.wait([api.getMe(), api.getProgress()]);
      final me = results[0];
      final progress = results[1];
      final createdAtRaw = me['created_at'] as String?;
      state = UserProfile(
        id: me['id'] as String? ?? state.id,
        name: me['name'] as String? ?? state.name,
        xp: (progress['xp'] as num?)?.toInt() ??
            (me['xp'] as num?)?.toInt() ??
            state.xp,
        streak: (progress['streak'] as num?)?.toInt() ??
            (me['streak'] as num?)?.toInt() ??
            state.streak,
        dailyGoalMinutes:
            (me['daily_goal_minutes'] as num?)?.toInt() ?? state.dailyGoalMinutes,
        experienceLevel:
            me['experience_level'] as String? ?? state.experienceLevel,
        focus: me['focus'] as String? ?? state.focus,
        hearAboutUs: me['hear_about_us'] as String? ?? state.hearAboutUs,
        avatarUrl: me['avatar_url'] as String?,
        createdAt:
            createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      );
    } catch (_) {}
  }

  void addXp(int amount) => state = state.copyWith(xp: state.xp + amount);
  void incrementStreak() => state = state.copyWith(streak: state.streak + 1);
  void setExperienceLevel(String level) =>
      state = state.copyWith(experienceLevel: level);
  void setDailyGoal(int minutes) =>
      state = state.copyWith(dailyGoalMinutes: minutes);
  void setFocus(String focus) => state = state.copyWith(focus: focus);
  void setName(String name) => state = state.copyWith(name: name);
  void setHearAboutUs(String source) =>
      state = state.copyWith(hearAboutUs: source);
}

/// Solved problem slugs fetched from the backend.
final solvedSlugsProvider = FutureProvider<Set<String>>((ref) async {
  final api = ref.read(apiServiceProvider);
  await api.ensureAuth();
  final slugs = await api.getSolvedSlugs();
  return Set<String>.from(slugs);
});

/// Per-category status data from backend (slug → {status, progress, ...}).
final categoryStatusDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiServiceProvider);
  await api.ensureAuth();
  return api.getCategoryStatuses();
});

/// Categories with live status from backend; falls back to hardcoded kCategories
/// while loading.
final categoriesProvider = Provider<List<Category>>((ref) {
  final statusAsync = ref.watch(categoryStatusDataProvider);
  return statusAsync.maybeWhen(
    data: (statusData) {
      final bySlug = {for (final s in statusData) s['slug'] as String: s};
      return kCategories.map((c) {
        final s = bySlug[c.slug];
        if (s == null) return c;
        final statusStr = s['status'] as String? ?? 'locked';
        final progress = (s['progress'] as num?)?.toDouble() ?? 0.0;
        return Category(
          id: c.id,
          name: c.name,
          slug: c.slug,
          icon: c.icon,
          glyph: c.glyph,
          orderIndex: c.orderIndex,
          status: statusStr == 'completed'
              ? CategoryStatus.completed
              : statusStr == 'current'
                  ? CategoryStatus.current
                  : CategoryStatus.locked,
          progress: progress,
        );
      }).toList();
    },
    orElse: () => kCategories,
  );
});

/// All problems.
final problemsProvider = Provider<List<Problem>>((ref) => kSampleProblems);

/// Problems filtered by category.
final problemsByCategoryProvider =
    Provider.family<List<Problem>, String>((ref, categoryId) {
  return ref
      .watch(problemsProvider)
      .where((p) => p.categoryId == categoryId)
      .toList();
});

/// Current bottom nav index.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// All problems fetched from the backend for the practice screen.
final allProblemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(apiServiceProvider);
  await api.ensureAuth();
  return api.getProblems(perPage: 200);
});

Difficulty _diffFromStr(String s) {
  switch (s) {
    case 'medium': return Difficulty.medium;
    case 'hard': return Difficulty.hard;
    default: return Difficulty.easy;
  }
}

int _xpForDiff(Difficulty d) {
  switch (d) {
    case Difficulty.easy: return 15;
    case Difficulty.medium: return 30;
    case Difficulty.hard: return 55;
  }
}

int _minsForDiff(Difficulty d) {
  switch (d) {
    case Difficulty.easy: return 8;
    case Difficulty.medium: return 15;
    case Difficulty.hard: return 25;
  }
}

/// Problems for a single category unit, with real solved status from backend.
final unitProblemsProvider =
    FutureProvider.autoDispose.family<List<UnitProblem>, String>((ref, categorySlug) async {
  final api = ref.read(apiServiceProvider);
  await api.ensureAuth();
  final problems = await api.getProblems(category: categorySlug, perPage: 50);
  final solvedSlugs = await ref.read(solvedSlugsProvider.future);
  return problems.map((p) {
    final diff = _diffFromStr(p['difficulty'] as String? ?? 'easy');
    return UnitProblem(
      slug: p['slug'] as String,
      title: p['title'] as String,
      difficulty: diff,
      xp: _xpForDiff(diff),
      minutes: _minsForDiff(diff),
      solved: solvedSlugs.contains(p['slug'] as String),
    );
  }).toList();
});
