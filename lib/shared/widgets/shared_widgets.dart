import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

// ─── Glass Card ───────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ??
              Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final IconData? icon;
  final bool isSmall;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isSmall
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigoPrimary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: isSmall ? 16 : 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── XP Progress Bar ──────────────────────────────────────────
class XPBar extends StatelessWidget {
  final int xp;
  final int level;
  final double progress;

  const XPBar({
    super.key,
    required this.xp,
    required this.level,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              '${xp % 500} / 500 XP',
              style: const TextStyle(
                
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.textMuted.withOpacity(0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.indigoPrimary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────
class StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                
                color: AppColors.indigoPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Color Dot ────────────────────────────────────────────────
class ColorDot extends StatelessWidget {
  final String hex;
  final double size;

  const ColorDot({super.key, required this.hex, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppUtils.hexToColor(hex),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Priority Badge ───────────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final int priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final label = priority == 3
        ? 'High'
        : priority == 2
            ? 'Medium'
            : 'Low';
    final color = priority == 3
        ? AppColors.roseAccent
        : priority == 2
            ? AppColors.amberAccent
            : AppColors.mintGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subject Color Picker ─────────────────────────────────────
class SubjectColorPicker extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const SubjectColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<SubjectColorPicker> createState() => _SubjectColorPickerState();
}

class _SubjectColorPickerState extends State<SubjectColorPicker> {
  final List<String> _colors = [
    '#6366F1', '#8B5CF6', '#EC4899', '#F43F5E',
    '#F97316', '#F59E0B', '#10B981', '#22D3EE',
    '#4F8EF7', '#A78BFA',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: _colors.map((hex) {
        final isSelected = hex == widget.selected;
        return GestureDetector(
          onTap: () => widget.onChanged(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppUtils.hexToColor(hex),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppUtils.hexToColor(hex).withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
