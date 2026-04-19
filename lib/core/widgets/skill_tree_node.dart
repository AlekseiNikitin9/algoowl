import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../theme/app_colors.dart';
import 'ck_icons.dart';

/// Skill tree node — 72px circle, surface-with-border when locked,
/// primary-blue when current, success-green when completed.
/// Zigzag offsets are applied by the parent (see redesign home.jsx).
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
  late final AnimationController _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.category.status == CategoryStatus.current) _pulse.repeat();
  }

  @override
  void didUpdateWidget(covariant SkillTreeNode old) {
    super.didUpdateWidget(old);
    if (widget.category.status == CategoryStatus.current) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.category.status;
    final locked = status == CategoryStatus.locked;
    final scheme = Theme.of(context).colorScheme;

    final bg = switch (status) {
      CategoryStatus.completed => AppColors.success,
      CategoryStatus.current => AppColors.primary,
      CategoryStatus.locked => scheme.surfaceContainerHighest,
    };
    final fg = locked ? AppColors.textDisabled : Colors.white;
    final shadow = switch (status) {
      CategoryStatus.completed => AppColors.successDark.withValues(alpha: 0.25),
      CategoryStatus.current => AppColors.primaryDark.withValues(alpha: 0.3),
      CategoryStatus.locked => Colors.transparent,
    };

    return GestureDetector(
      onTapDown: locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: locked ? null : (_) => setState(() => _pressed = false),
      onTapCancel: locked ? null : () => setState(() => _pressed = false),
      onTap: locked ? null : widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.96 : 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (status == CategoryStatus.current)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final v = _pulse.value;
                      return Container(
                        width: 72 + v * 36,
                        height: 72 + v * 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5 * (1 - v)),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: locked ? Border.all(color: scheme.outline) : null,
                    boxShadow: locked
                        ? null
                        : [
                            BoxShadow(
                              color: shadow,
                              offset: Offset(0, status == CategoryStatus.current ? 8 : 6),
                              blurRadius: status == CategoryStatus.current ? 20 : 14,
                            ),
                          ],
                  ),
                  child: Center(
                    child: _nodeIcon(status, fg),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 96,
            child: Text(
              widget.category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 16 / 12,
                color: locked ? AppColors.textDisabled : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeIcon(CategoryStatus status, Color color) {
    switch (status) {
      case CategoryStatus.completed:
        return CkIcon.check(size: 28, color: color);
      case CategoryStatus.locked:
        return CkIcon.lock(size: 26, color: color);
      case CategoryStatus.current:
        return CkIcon.play(size: 24, color: color);
    }
  }
}
