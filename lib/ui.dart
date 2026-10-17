import 'package:flutter/material.dart';

const ink = Color(0xFF111111);
const line = Color(0xFFBBBBBB);
const soft = Color(0xFFDDDDDD);
const rule = Color(0xFFE5E5E5);
const muted = Color(0xFF666666);
const danger = Color(0xFFC00000);

ThemeData buildTheme() {
  final radius = BorderRadius.circular(6);
  OutlineInputBorder border(Color c) =>
      OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: c));

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: ink,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: ink,
      error: danger,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border(line),
      enabledBorder: border(line),
      focusedBorder: border(ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: const BorderSide(color: ink),
        shape: RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ink),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? ink : null,
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

/// Keeps content centered and at most 720px wide, like the web page.
Widget centered(Widget child) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: child),
    );

/// Label above a field, like the web forms.
class Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const Labeled(this.label, this.child, {super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          child,
        ],
      );
}

/// Pill chip: black when selected, white with a grey border otherwise.
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const AppChip(this.label, this.selected, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label, style: TextStyle(color: selected ? Colors.white : ink, fontSize: 14)),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: ink,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(color: selected ? ink : line),
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
      );
}

/// Small outlined button used for "Delete".
final ButtonStyle smallButton = OutlinedButton.styleFrom(
  foregroundColor: ink,
  side: const BorderSide(color: soft),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  minimumSize: const Size(0, 32),
  textStyle: const TextStyle(fontSize: 13),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
);

/// Bordered box, like the web ".panel".
Widget panel({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: soft),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );

Future<bool> confirm(BuildContext context, String message) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
      ],
    ),
  );
  return result == true;
}