import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Shows a plain chocolate toast (no undo).
void showAppToast(BuildContext context, String message,
    {int durationSeconds = 3}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: Duration(seconds: durationSeconds),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: cream, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: GoogleFonts.inter(fontSize: 14, color: cream)),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Shows a chocolate toast with an Undo pill.
/// [onUndo] is called when the user taps Undo.
void showUndoToast(
  BuildContext context,
  String message, {
  required Future<void> Function() onUndo,
  required String undoSemanticLabel,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: _UndoContent(
        message: message,
        onUndo: () {
          messenger.hideCurrentSnackBar();
          return onUndo();
        },
        undoSemanticLabel: undoSemanticLabel,
      ),
    ),
  );
}

class _UndoContent extends StatefulWidget {
  final String message;
  final Future<void> Function() onUndo;
  final String undoSemanticLabel;

  const _UndoContent({
    required this.message,
    required this.onUndo,
    required this.undoSemanticLabel,
  });

  @override
  State<_UndoContent> createState() => _UndoContentState();
}

class _UndoContentState extends State<_UndoContent> {
  bool _undoing = false;

  Future<void> _doUndo() async {
    if (_undoing) return;
    setState(() => _undoing = true);
    try {
      await widget.onUndo();
    } finally {
      if (mounted) setState(() => _undoing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: cream, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.message,
              style: GoogleFonts.inter(fontSize: 14, color: cream),
            ),
          ),
          const SizedBox(width: 8),
          // Undo pill
          Semantics(
            button: true,
            label: widget.undoSemanticLabel,
            child: GestureDetector(
              onTap: _undoing ? null : _doUndo,
              child: Container(
                constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: cream.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: _undoing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(cream),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.undo, color: cream, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'Undo',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cream),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
