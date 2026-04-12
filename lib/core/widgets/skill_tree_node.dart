import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Milestone icons that appear between skill tree nodes at key thresholds.
/// Shown above node index 0, 5, 9, 13 (start, mid-tier, advanced, god-tier).
const _milestoneData = <int, (String emoji, String label)>{
  0: ('🌱', 'Humble Beginner'),
  5: ('⚡', 'Getting Dangerous'),
  9: ('🔥', 'Advanced Grinder'),
  13: ('🧠', 'Gigachad Dev'),
};

/// A single node in the skill tree - Duolingo-style with zigzag layout.
class SkillTreeNode extends StatefulWidget {
  final Category category;
  final int index;
  final VoidCallback? onTap;

  const SkillTreeNode({
    super.key,
    required this.category,
    required this.index,
    this.onTap,
  });

  @override
  State<SkillTreeNode> createState() => _SkillTreeNodeState();
}

class _SkillTreeNodeState extends State<SkillTreeNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.category.status == CategoryStatus.current) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _bgColor(ColorScheme colorScheme) {
    switch (widget.category.status) {
      case CategoryStatus.completed:
        return AppColors.success;
      case CategoryStatus.current:
        return AppColors.primary;
      case CategoryStatus.locked:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _iconColor(ColorScheme colorScheme) {
    switch (widget.category.status) {
      case CategoryStatus.completed:
      case CategoryStatus.current:
        return Colors.white;
      case CategoryStatus.locked:
        return AppColors.textDisabled;
    }
  }

  /// Zigzag: offset alternates left/center/right based on index pattern.
  /// Pattern: center → right → center → left → center → right → ...
  double _horizontalOffset(double maxOffset) {
    // Use a 4-step cycle: 0=center, 1=right, 2=center, 3=left
    switch (widget.index % 4) {
      case 0:
        return 0;
      case 1:
        return maxOffset;
      case 2:
        return 0;
      case 3:
        return -maxOffset;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestone = _milestoneData[widget.index];
    final screenWidth = MediaQuery.of(context).size.width;
    final maxOffset = screenWidth * 0.22;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = _bgColor(colorScheme);
    final iconColor = _iconColor(colorScheme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Milestone banner shown above certain nodes
        if (milestone != null) _buildMilestoneBanner(milestone, colorScheme),

        // Node with zigzag offset
        Transform.translate(
          offset: Offset(_horizontalOffset(maxOffset), 0),
          child: GestureDetector(
            onTap: widget.category.status != CategoryStatus.locked
                ? widget.onTap
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring for current node
                    if (widget.category.status == CategoryStatus.current)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.4),
                            child: Opacity(
                              opacity: 0.6 * (1.0 - _pulseController.value),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    // Main circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: widget.category.status == CategoryStatus.locked
                            ? Border.all(color: colorScheme.outline, width: 2)
                            : null,
                        boxShadow:
                            widget.category.status != CategoryStatus.locked
                                ? [
                                    BoxShadow(
                                      color: bgColor.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                      ),
                      child: Icon(
                        widget.category.status == CategoryStatus.completed
                            ? Icons.check_rounded
                            : widget.category.icon,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                SizedBox(
                  width: 90,
                  child: Text(
                    widget.category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: widget.category.status == CategoryStatus.locked
                          ? AppColors.textDisabled
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneBanner(
    (String emoji, String label) milestone,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.space6,
        bottom: AppSpacing.space4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(milestone.$1, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  milestone.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
