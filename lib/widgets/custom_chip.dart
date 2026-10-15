import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Chip minimalista em estilo Apple para filtros de categorias e ocasiões
class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  const CustomChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.textLight : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.textLight : AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
