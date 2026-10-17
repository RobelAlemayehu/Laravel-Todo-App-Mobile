import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Chocolate & cream themed confirm dialog.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool isDanger = false,
  Future<void> Function()? onConfirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: choc900.withOpacity(0.45),
    builder: (ctx) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDanger: isDanger,
      onConfirm: onConfirm,
    ),
  );
  return result == true;
}

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;
  final Future<void> Function()? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.isDanger = false,
    this.onConfirm,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _loading = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm != null) {
      setState(() => _loading = true);
      try {
        await widget.onConfirm!();
        if (mounted) Navigator.pop(context, true);
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.fraunces(
                    fontSize: 20, fontWeight: FontWeight.w700, color: choc900),
              ),
              const SizedBox(height: 10),
              Text(
                widget.message,
                style: GoogleFonts.inter(fontSize: 14, color: choc500),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: choc500),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: choc700),
                        )
                      : widget.isDanger
                          ? OutlinedButton(
                              onPressed: _handleConfirm,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: appDanger,
                                side: const BorderSide(color: appDanger),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              child: Text(widget.confirmLabel,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            )
                          : FilledButton(
                              onPressed: _handleConfirm,
                              style: FilledButton.styleFrom(
                                backgroundColor: choc700,
                                foregroundColor: cream,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              child: Text(widget.confirmLabel,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
