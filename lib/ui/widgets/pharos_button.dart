import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PharosButtonStyle { primary, secondary, outline, ghost, danger }

class PharosButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final PharosButtonStyle style;
  final double? width;
  final double height;
  final bool fullWidth;

  const PharosButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.style = PharosButtonStyle.primary,
    this.width,
    this.height = 56,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;
    
    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: _buildButton(context, isEnabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled) {
    final content = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.text),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          );

    final void Function()? wrappedOnPressed = isEnabled
        ? () {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        : null;

    switch (style) {
      case PharosButtonStyle.primary:
        return ElevatedButton(
          onPressed: wrappedOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.text,
            disabledBackgroundColor: AppColors.divider,
            disabledForegroundColor: AppColors.border,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        );
      case PharosButtonStyle.secondary:
        return ElevatedButton(
          onPressed: wrappedOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.text.withOpacity(0.1),
            foregroundColor: AppColors.text,
            disabledBackgroundColor: AppColors.text.withOpacity(0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        );
      case PharosButtonStyle.outline:
        return OutlinedButton(
          onPressed: wrappedOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentText,
            side: BorderSide(color: isEnabled ? AppColors.accentText : AppColors.divider, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        );
      case PharosButtonStyle.ghost:
        return TextButton(
          onPressed: wrappedOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        );
      case PharosButtonStyle.danger:
        return ElevatedButton(
          onPressed: wrappedOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.text,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: content,
        );
    }
  }
}
