import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Caramel circle with user's initial in cream.
class AvatarCircle extends StatelessWidget {
  final String initial;
  final double size;

  const AvatarCircle({super.key, required this.initial, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: caramel,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            color: cream,
          ),
        ),
      ),
    );
  }
}
