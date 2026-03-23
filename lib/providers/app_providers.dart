import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../models/category.dart';
import '../models/problem.dart';

/// Whether onboarding has been completed.
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

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
          xp: 340,
          streak: 7,
        ));

  void addXp(int amount) => state = state.copyWith(xp: state.xp + amount);
  void incrementStreak() =>
      state = state.copyWith(streak: state.streak + 1);
  void setExperienceLevel(String level) =>
      state = state.copyWith(experienceLevel: level);
  void setDailyGoal(int minutes) =>
      state = state.copyWith(dailyGoalMinutes: minutes);
  void setFocus(String focus) => state = state.copyWith(focus: focus);
  void setName(String name) => state = state.copyWith(name: name);
}

/// Categories for the skill tree.
final categoriesProvider = Provider<List<Category>>((ref) => kCategories);

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
