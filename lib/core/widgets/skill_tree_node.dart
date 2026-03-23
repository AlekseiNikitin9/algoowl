import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A single node in the skill tree (Duolingo-style).
class SkillTreeNode extends StatefulWidget {
  final Category category;
  final VoidCallback? onTap;

  const SkillTreeNode({
    super.key,
    required this.category,
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

  Color get _bgColor {
    switch (widget.category.status) {
      case CategoryStatus.completed:
        return AppColors.success;
      case CategoryStatus.current:
        return AppColors.primary;
      case CategoryStatus.locked:
        return AppColors.surfaceAlt;
    }
  }

  Color get _iconColor {
    switch (widget.category.status) {
      case CategoryStatus.completed:
      case CategoryStatus.current:
        return Colors.white;
      case CategoryStatus.locked:
        return AppColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  color: _bgColor,
                  shape: BoxShape.circle,
                  border: widget.category.status == CategoryStatus.locked
                      ? Border.all(color: AppColors.border, width: 2)
                      : null,
                  boxShadow: widget.category.status != CategoryStatus.locked
                      ? [
                          BoxShadow(
                            color: _bgColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.category.status == CategoryStatus.completed
                      ? Icons.check
                      : widget.category.icon,
                  color: _iconColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          SizedBox(
            width: 80,
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
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
