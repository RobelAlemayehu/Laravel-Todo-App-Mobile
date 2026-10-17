import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum AppChipVariant { neutral, overdue, dueSoon, success, muted }

/// Status chip with optional leading colored dot.
class AppStatusChip extends StatelessWidget {
  final String label;
  final AppChipVariant variant;

  const AppStatusChip(this.label, {super.key, this.variant = AppChipVariant.neutral});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, dotColor) = switch (variant) {
      AppChipVariant.overdue => (appDangerBg, appDanger, appDanger),
      AppChipVariant.dueSoon => (const Color(0xFFFFF3E0), appDueSoon, appDueSoon),
      AppChipVariant.success => (const Color(0xFFEBF3E0), appSuccess, appSuccess),
      AppChipVariant.muted => (appSurface2, appMuted, appMuted),
      AppChipVariant.neutral => (appSurface2, choc500, choc500),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bgColor.withOpacity(0.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Tag chip: muted cream, no dot.
class AppTagChip extends StatelessWidget {
  final String label;
  final bool removable;
  final VoidCallback? onRemove;

  const AppTagChip(this.label, {super.key, this.removable = false, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 8, right: removable ? 4 : 8, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: appSurface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: GoogleFonts.inter(fontSize: 11, color: appMuted),
          ),
          if (removable) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 13, color: appMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Category chip with a colored dot.
class AppCategoryChip extends StatelessWidget {
  final String name;
  final Color dotColor;

  const AppCategoryChip({super.key, required this.name, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: appSurface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w500, color: choc500),
          ),
        ],
      ),
    );
  }
}

/// Selectable chip for filters / tag selection in form.
class AppSelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor; // optional leading dot

  const AppSelectableChip(
    this.label, {
    super.key,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? choc700 : appSurface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? choc700 : appBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? cream : dotColor!,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? cream : choc500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
