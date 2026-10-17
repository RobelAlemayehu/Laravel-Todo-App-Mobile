import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Thin 4px animated progress bar.
class ProgressBarThin extends StatelessWidget {
  final double value; // 0.0 to 1.0

  const ProgressBarThin({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final animate = !MediaQuery.of(context).disableAnimations;
        return Container(
          height: 4,
          decoration: BoxDecoration(
            color: appSurface2,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration:
                    animate ? const Duration(milliseconds: 400) : Duration.zero,
                curve: Curves.easeOut,
                width: constraints.maxWidth * value.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: choc700,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
