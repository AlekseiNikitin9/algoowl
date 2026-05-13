import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';
import 'models/user_profile.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize API service and resolve initial auth + onboarding state
  final api = ApiService();
  bool onboardingDone = false;
  UserProfile? initialProfile;

  try {
    final hasSession = await api.init();
    if (hasSession) {
      final results = await Future.wait([api.getMe(), api.getProgress()]);
      final me = results[0];
      final progress = results[1];
      onboardingDone = me['onboarding_complete'] == true;
      final createdAtRaw = me['created_at'] as String?;
      initialProfile = UserProfile(
        id: me['id'] as String? ?? 'local-user',
        name: me['name'] as String? ?? 'Learner',
        xp: (progress['xp'] as num?)?.toInt() ?? 0,
        streak: (progress['streak'] as num?)?.toInt() ?? 0,
        dailyGoalMinutes: (me['daily_goal_minutes'] as num?)?.toInt() ?? 10,
        experienceLevel: me['experience_level'] as String? ?? 'beginner',
        focus: me['focus'] as String? ?? 'both',
        avatarUrl: me['avatar_url'] as String?,
        createdAt:
            createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null,
      );
    }
  } catch (_) {
    // Backend unreachable - fall back to local-only mode
  }

  runApp(ProviderScope(
    overrides: [
      apiServiceProvider.overrideWithValue(api),
      onboardingCompleteProvider.overrideWith((ref) => onboardingDone),
      if (initialProfile != null)
        userProfileProvider.overrideWith(
          (ref) => UserProfileNotifier.withProfile(initialProfile!),
        ),
    ],
    child: const CodekataApp(),
  ));
}

class CodekataApp extends ConsumerWidget {
  const CodekataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Codekata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
