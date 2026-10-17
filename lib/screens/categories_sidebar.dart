import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category.dart';
import '../models/tag.dart';
import '../providers.dart';
import '../services/api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/confirm_dialog.dart';

/// Opens the categories & tags panel as a bottom sheet (phone).
Future<void> showCategoriesSidebar(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxHeight: 600),
    builder: (_) => const _CategoriesSidebarContent(),
  );
}

/// Sticky sidebar widget for wide screens.
class CategoriesSidebarPanel extends StatelessWidget {
  const CategoriesSidebarPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: appBorder)),
        color: appSurface,
      ),
      child: const _CategoriesSidebarContent(isPanel: true),
    );
  }
}

class _CategoriesSidebarContent extends ConsumerStatefulWidget {
  final bool isPanel;
  const _CategoriesSidebarContent({this.isPanel = false});

  @override
  ConsumerState<_CategoriesSidebarContent> createState() =>
      _CategoriesSidebarContentState();
}

class _CategoriesSidebarContentState
    extends ConsumerState<_CategoriesSidebarContent> {
  final _catCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  @override
  void dispose() {
    _catCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _catCtrl.text.trim();
    if (name.isEmpty) return;
    try {
      await ref.read(apiProvider).createCategory(name);
      _catCtrl.clear();
      ref.invalidate(categoriesProvider);
    } catch (e) {
      if (mounted) showAppToast(context, Api.errorMessage(e));
    }
  }

  Future<void> _deleteCategory(Category c) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete category?',
      message:
          '"${c.name}" and its ${c.todosCount} todo${c.todosCount == 1 ? '' : 's'} will lose this category. This can\'t be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(apiProvider).deleteCategory(c.id);
      ref.invalidate(categoriesProvider);
      if (mounted) showAppToast(context, 'Category deleted');
    } catch (e) {
      if (mounted) showAppToast(context, Api.errorMessage(e));
    }
  }

  Future<void> _addTag() async {
    final name = _tagCtrl.text.trim();
    if (name.isEmpty) return;
    try {
      await ref.read(apiProvider).createTag(name);
      _tagCtrl.clear();
      ref.invalidate(tagsProvider);
      if (mounted) showAppToast(context, 'Tag added');
    } catch (e) {
      if (mounted) showAppToast(context, Api.errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final tags = ref.watch(tagsProvider);

    return Column(
      mainAxisSize: widget.isPanel ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Handle (bottom sheet only)
        if (!widget.isPanel)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Text(
                'Categories & Tags',
                style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: choc900),
              ),
              const Spacer(),
              if (!widget.isPanel)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: choc500),
                  iconSize: 20,
                  splashRadius: 20,
                ),
            ],
          ),
        ),
        const Divider(color: appBorder, height: 1),

        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Categories ─────────────────────────────────────────────
                _sectionLabel('CATEGORIES'),
                const SizedBox(height: 10),

                // Add category input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _catCtrl,
                        onSubmitted: (_) => _addCategory(),
                        style:
                            GoogleFonts.inter(fontSize: 14, color: choc900),
                        decoration: const InputDecoration(
                          hintText: 'New category...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _addCategory,
                      style: FilledButton.styleFrom(
                        backgroundColor: choc700,
                        foregroundColor: cream,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        minimumSize: const Size(0, 40),
                      ),
                      child:
                          Text('Add', style: GoogleFonts.inter(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                categories.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: choc700)),
                  error: (e, _) => Text(Api.errorMessage(e),
                      style: GoogleFonts.inter(fontSize: 13, color: appDanger)),
                  data: (list) => list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('No categories yet',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: appMuted)),
                        )
                      : Column(
                          children: list
                              .map((c) => _CategoryRow(
                                    category: c,
                                    onDelete: () => _deleteCategory(c),
                                  ))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 24),
                const Divider(color: appBorder),
                const SizedBox(height: 16),

                // ── Tags ───────────────────────────────────────────────────
                _sectionLabel('TAGS'),
                const SizedBox(height: 10),

                // Add tag
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagCtrl,
                        onSubmitted: (_) => _addTag(),
                        style:
                            GoogleFonts.inter(fontSize: 14, color: choc900),
                        decoration: const InputDecoration(
                          hintText: 'New tag...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _addTag,
                      style: FilledButton.styleFrom(
                        backgroundColor: choc700,
                        foregroundColor: cream,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        minimumSize: const Size(0, 40),
                      ),
                      child:
                          Text('Add', style: GoogleFonts.inter(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                tags.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: choc700)),
                  error: (e, _) => Text(Api.errorMessage(e),
                      style: GoogleFonts.inter(fontSize: 13, color: appDanger)),
                  data: (list) => list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('No tags yet',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: appMuted)),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: list
                              .map((t) => _TagPill(tag: t))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: choc500,
        ),
      );
}

class _CategoryRow extends StatelessWidget {
  final Category category;
  final VoidCallback onDelete;

  const _CategoryRow({required this.category, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dot = categoryColor(category.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.name,
              style:
                  GoogleFonts.inter(fontSize: 14, color: choc900),
            ),
          ),
          Text(
            '${category.todosCount}',
            style: GoogleFonts.inter(fontSize: 12, color: appMuted),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Delete category',
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              color: appMuted,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final Tag tag;
  const _TagPill({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: appSurface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('#${tag.name}',
              style: GoogleFonts.inter(fontSize: 12, color: choc500)),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Tag deletion requires a backend endpoint',
            child: Icon(Icons.close, size: 13, color: appMuted.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
