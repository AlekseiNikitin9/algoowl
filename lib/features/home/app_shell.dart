import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ck_icons.dart';
import '../../providers/app_providers.dart';
import '../home/home_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';

/// Shell with a glass-morphism bottom nav — Home · Practice · League · You.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    PracticeScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: _GlassBottomNav(
        activeIndex: index,
        onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomNav({required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgTint = isDark
        ? AppColors.darkBg.withValues(alpha: 0.72)
        : AppColors.bg.withValues(alpha: 0.72);
    final borderColor = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.35)
        : AppColors.borderStrong.withValues(alpha: 0.35);

    const tabs = <_Tab>[
      _Tab(label: 'Home', kind: _TabKind.home),
      _Tab(label: 'Practice', kind: _TabKind.book),
      _Tab(label: 'League', kind: _TabKind.trophy),
      _Tab(label: 'You', kind: _TabKind.user),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: bgTint,
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          ),
          padding: EdgeInsets.only(
            top: 6,
            bottom: MediaQuery.paddingOf(context).bottom + 6,
            left: 12,
            right: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < tabs.length; i++)
                _NavItem(
                  tab: tabs[i],
                  active: i == activeIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TabKind { home, book, trophy, user }

class _Tab {
  final String label;
  final _TabKind kind;
  const _Tab({required this.label, required this.kind});
}

class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.tab, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.primary
        : (Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkTextSecondary
            : AppColors.textDisabled);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (tab.kind) {
              _TabKind.home => CkIcon.home(color: color),
              _TabKind.book => CkIcon.book(color: color),
              _TabKind.trophy => CkIcon.trophy(color: color),
              _TabKind.user => CkIcon.user(color: color),
            },
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.02 * 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
