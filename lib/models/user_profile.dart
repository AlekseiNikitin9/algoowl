class UserProfile {
  final String id;
  final String name;
  final int xp;
  final int streak;
  final int dailyGoalMinutes;
  final String experienceLevel; // beginner, intermediate, advanced
  final String focus; // interview, learn, both

  const UserProfile({
    required this.id,
    required this.name,
    this.xp = 0,
    this.streak = 0,
    this.dailyGoalMinutes = 10,
    this.experienceLevel = 'beginner',
    this.focus = 'both',
  });

  UserProfile copyWith({
    String? name,
    int? xp,
    int? streak,
    int? dailyGoalMinutes,
    String? experienceLevel,
    String? focus,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      focus: focus ?? this.focus,
    );
  }
}
