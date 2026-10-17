import 'package:flutter/material.dart';

// ── Backgrounds ──────────────────────────────────────────────────────────────
const Color appBg = Color(0xFFF7F0E3);
const Color appSurface = Color(0xFFFFFAF0);
const Color appSurface2 = Color(0xFFF1E7D4);
const Color appBorder = Color(0xFFE4D5BC);

// ── Chocolate scale ───────────────────────────────────────────────────────────
const Color choc900 = Color(0xFF2B1B12); // primary text, toast bg
const Color choc700 = Color(0xFF4B2E1E); // primary buttons, FAB
const Color choc600 = Color(0xFF5E3B27); // pressed state
const Color choc500 = Color(0xFF7A5239); // secondary text / icons
const Color appMuted = Color(0xFF9A8473); // muted text

// ── Accent & semantics ────────────────────────────────────────────────────────
const Color caramel = Color(0xFFB7794A);   // focus border, selected
const Color appSuccess = Color(0xFF5F7A3A);
const Color appDueSoon = Color(0xFFB7791F);
const Color appDanger = Color(0xFFA33A2B);
const Color appDangerBg = Color(0xFFF8E4DF);

// ── On-dark ───────────────────────────────────────────────────────────────────
const Color cream = Color(0xFFFFFAF0); // text on chocolate

// ── Category dot palette (deterministic from id % length) ─────────────────────
const List<Color> categoryDotPalette = [
  Color(0xFF7A5239), // choc500
  Color(0xFF5F7A3A), // green
  Color(0xFFB7794A), // caramel
  Color(0xFF4B6E7A), // teal
  Color(0xFF7A3A5E), // plum
  Color(0xFF5E6B2B), // olive
  Color(0xFF7A4B2E), // rust
  Color(0xFF2B5E7A), // slate blue
];

Color categoryColor(int id) => categoryDotPalette[id % categoryDotPalette.length];
