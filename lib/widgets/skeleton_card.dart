import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shimmering skeleton card placeholder.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.9).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return _buildCard(0.6);
    }
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => _buildCard(_opacity.value),
    );
  }

  Widget _buildCard(double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(22, 22, radius: 5),
                const SizedBox(width: 12),
                Expanded(child: _box(15, double.infinity)),
                const SizedBox(width: 32),
                _box(15, 60),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(12, 200),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _box(20, 70, radius: 999),
                      const SizedBox(width: 6),
                      _box(20, 90, radius: 999),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double height, double width, {double radius = 6}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: appSurface2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
