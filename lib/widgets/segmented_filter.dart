import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// All / Active / Done segmented filter with count badges and animated indicator.
class SegmentedFilter extends StatefulWidget {
  final int selectedIndex; // 0=All, 1=Active, 2=Done
  final int allCount;
  final int activeCount;
  final int doneCount;
  final ValueChanged<int> onChanged;

  const SegmentedFilter({
    super.key,
    required this.selectedIndex,
    required this.allCount,
    required this.activeCount,
    required this.doneCount,
    required this.onChanged,
  });

  @override
  State<SegmentedFilter> createState() => _SegmentedFilterState();
}

class _SegmentedFilterState extends State<SegmentedFilter> {
  @override
  Widget build(BuildContext context) {
    final labels = ['All', 'Active', 'Done'];
    final counts = [widget.allCount, widget.activeCount, widget.doneCount];
    final animate = !MediaQuery.of(context).disableAnimations;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: appSurface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segWidth = constraints.maxWidth / 3;
          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: animate
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                curve: Curves.easeOut,
                left: widget.selectedIndex * segWidth + 2,
                top: 2,
                bottom: 2,
                width: segWidth - 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: appSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: appBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F2B1B12),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              // Segment buttons
              Row(
                children: List.generate(3, (i) {
                  final selected = widget.selectedIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onChanged(i),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              labels[i],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected ? choc900 : appMuted,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _CountBadge(counts[i], selected: selected),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool selected;
  const _CountBadge(this.count, {required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? choc700 : appBorder,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: selected ? cream : choc500,
        ),
      ),
    );
  }
}
