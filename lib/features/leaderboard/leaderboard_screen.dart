import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space6),
              Text('Leaderboard', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.space1),
              Text(
                'Weekly XP ranking',
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Podium top 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PodiumTile(rank: 2, name: 'Alice', xp: 520),
                  _PodiumTile(rank: 1, name: 'You', xp: 680, isUser: true),
                  _PodiumTile(rank: 3, name: 'Bob', xp: 490),
                ],
              ),

              const SizedBox(height: AppSpacing.space6),
              const Divider(),
              const SizedBox(height: AppSpacing.space3),

              // Rest of leaderboard
              Expanded(
                child: ListView(
                  children: const [
                    _LeaderboardRow(rank: 4, name: 'Charlie', xp: 410),
                    _LeaderboardRow(rank: 5, name: 'Diana', xp: 380),
                    _LeaderboardRow(rank: 6, name: 'Eve', xp: 340),
                    _LeaderboardRow(rank: 7, name: 'Frank', xp: 290),
                    _LeaderboardRow(rank: 8, name: 'Grace', xp: 260),
                    _LeaderboardRow(rank: 9, name: 'Heidi', xp: 230),
                    _LeaderboardRow(rank: 10, name: 'Ivan', xp: 200),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final bool isUser;

  const _PodiumTile({
    required this.rank,
    required this.name,
    required this.xp,
    this.isUser = false,
  });

  double get _height {
    switch (rank) {
      case 1:
        return 100;
      case 2:
        return 76;
      case 3:
        return 60;
      default:
        return 50;
    }
  }

  Color get _medalColor {
    switch (rank) {
      case 1:
        return AppColors.gold;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: isUser
              ? AppColors.primaryLight
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person,
            color: isUser ? AppColors.primary : colorScheme.onSurfaceVariant,
            size: rank == 1 ? 28 : 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTypography.label.copyWith(
            color: isUser ? AppColors.primary : colorScheme.onSurface,
          ),
        ),
        Text(
          '$xp XP',
          style: AppTypography.caption.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: 6),
        // Podium bar
        Container(
          width: 70,
          height: _height,
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.sm),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: AppTypography.h2.copyWith(
              color: isUser ? Colors.white : _medalColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: AppTypography.bodyLg
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(Icons.person,
                color: colorScheme.onSurfaceVariant, size: 18),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(name, style: AppTypography.bodyLg),
          ),
          Text(
            '$xp XP',
            style: AppTypography.label.copyWith(color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}
