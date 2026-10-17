import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, dangerGhost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    Widget child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _foreground(disabled),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          );

    final btn = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          style: _primaryStyle(disabled),
          onPressed: disabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          style: _secondaryStyle(),
          onPressed: disabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          style: _ghostStyle(),
          onPressed: disabled ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.dangerGhost => TextButton(
          style: _dangerGhostStyle(),
          onPressed: disabled ? null : onPressed,
          child: child,
        ),
    };

    if (isFullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }

  Color _foreground(bool disabled) {
    if (disabled) return appMuted;
    return switch (variant) {
      AppButtonVariant.primary => cream,
      AppButtonVariant.secondary => choc700,
      AppButtonVariant.ghost => choc700,
      AppButtonVariant.dangerGhost => appDanger,
    };
  }

  ButtonStyle _primaryStyle(bool disabled) => FilledButton.styleFrom(
        backgroundColor: disabled ? appSurface2 : choc700,
        foregroundColor: disabled ? appMuted : cream,
        disabledBackgroundColor: appSurface2,
        disabledForegroundColor: appMuted,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(0, 48),
      );

  ButtonStyle _secondaryStyle() => OutlinedButton.styleFrom(
        foregroundColor: choc700,
        side: const BorderSide(color: appBorder),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
      );

  ButtonStyle _ghostStyle() => TextButton.styleFrom(
        foregroundColor: choc700,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
      );

  ButtonStyle _dangerGhostStyle() => TextButton.styleFrom(
        foregroundColor: appDanger,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
      );
}
