import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Card no padrão estético Apple: cantos curvos suaves, borda sutil e sombra difusa
class AppleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;
  final Border? border;

  const AppleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 20,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
