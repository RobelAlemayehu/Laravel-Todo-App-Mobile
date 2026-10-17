import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Chocolate-fill rounded checkbox with a pop animation on toggle.
class AppCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppCheckbox({super.key, required this.value, this.onChanged});

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 1.22).chain(
      CurveTween(curve: Curves.easeOut),
    ).animate(_ctrl);
  }

  @override
  void didUpdateWidget(AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.of(context).disableAnimations;
    return Semantics(
      checked: widget.value,
      label: widget.value ? 'Mark as active' : 'Mark as completed',
      child: GestureDetector(
        onTap: widget.onChanged == null
            ? null
            : () => widget.onChanged!(!widget.value),
        child: animate
            ? ScaleTransition(
                scale: _scale,
                child: _box(),
              )
            : _box(),
      ),
    );
  }

  Widget _box() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: widget.value ? choc700 : appSurface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: widget.value ? choc700 : appBorder,
          width: 1.5,
        ),
        boxShadow: widget.value
            ? [
                BoxShadow(
                  color: choc700.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: widget.value
          ? const Icon(Icons.check, size: 14, color: cream)
          : null,
    );
  }
}
