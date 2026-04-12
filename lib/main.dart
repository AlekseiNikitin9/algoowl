import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';
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

  try {
    final hasSession = await api.init();
    if (hasSession) {
      final progress = await api.getProgress();
      onboardingDone = progress['onboarding_complete'] == true;
    }
  } catch (_) {
    // Backend unreachable - fall back to local-only mode
  }

  runApp(ProviderScope(
    overrides: [
      apiServiceProvider.overrideWithValue(api),
      onboardingCompleteProvider.overrideWith((ref) => onboardingDone),
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
