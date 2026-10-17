import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Cream card with 14-radius, 1px border and warm soft shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: choc700.withOpacity(0.06),
        highlightColor: choc700.withOpacity(0.04),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? appSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appBorder, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x144B2E1E), // choc700 @ ~8%
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
