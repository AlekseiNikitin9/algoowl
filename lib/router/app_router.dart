import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/home/app_shell.dart';
import '../features/lesson/lesson_screen.dart';
import '../features/code_editor/code_editor_screen.dart';
import '../features/code_editor/accepted_screen.dart';
import '../features/unit/unit_screen.dart';
import '../providers/app_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: onboardingComplete ? '/' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
      ),
      GoRoute(
        path: '/unit/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: UnitScreen(slug: slug),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/lesson/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: LessonScreen(problemSlug: slug),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/editor/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CodeEditorScreen(problemSlug: slug),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                )),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/accepted/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final complexity = state.extra as Map<String, String>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AcceptedScreen(problemSlug: slug, complexity: complexity),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ],
    redirect: (context, state) {
      if (!onboardingComplete && state.uri.path != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingComplete && state.uri.path == '/onboarding') {
        return '/';
      }
      return null;
    },
  );
});
