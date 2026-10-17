import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category.dart';
import '../models/tag.dart';
import '../models/todo.dart';
import '../providers.dart';
import '../services/api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Opens the todo form as a bottom sheet (phone) or dialog (tablet).
Future<bool?> openTodoForm(BuildContext context, {Todo? todo}) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 600) {
    return showDialog<bool>(
      context: context,
      barrierColor: choc900.withOpacity(0.4),
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
          child: TodoFormSheet(todo: todo),
        ),
      ),
    );
  } else {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TodoFormSheet(todo: todo),
    );
  }
}

class TodoFormSheet extends ConsumerStatefulWidget {
  final Todo? todo;
  const TodoFormSheet({super.key, this.todo});

  @override
  ConsumerState<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends ConsumerState<TodoFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  final _newTag = TextEditingController();
  DateTime? _due;
  int? _categoryId;
  late Set<int> _tagIds;
  bool _saving = false;
  String? _titleError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    final t = widget.todo;
    _title = TextEditingController(text: t?.title);
    _desc = TextEditingController(text: t?.description);
    _due = t?.dueDate;
    _categoryId = t?.category?.id;
    _tagIds = {...?t?.tags.map((x) => x.id)};
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _newTag.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _setQuickDate(DateTime d) => setState(() => _due = d);

  Future<void> _addTag() async {
    final name = _newTag.text.trim();
    if (name.isEmpty) return;
    try {
      final tag = await ref.read(apiProvider).createTag(name);
      _newTag.clear();
      ref.invalidate(tagsProvider);
      if (mounted) setState(() => _tagIds.add(tag.id));
    } catch (e) {
      if (mounted) setState(() => _generalError = Api.errorMessage(e));
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required.');
      return;
    }
    setState(() {
      _saving = true;
      _titleError = null;
      _generalError = null;
    });

    final data = <String, dynamic>{
      'title': title,
      'description':
          _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'due_date': _due == null ? null : formatDate(_due!),
      'category_id': _categoryId,
      'tags': _tagIds.toList(),
    };

    try {
      final api = ref.read(apiProvider);
      if (widget.todo == null) {
        await api.createTodo(data);
      } else {
        await api.updateTodo(widget.todo!.id, data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _generalError = Api.errorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDue(DateTime d) => formatDisplayDate(d);

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final isPhone = MediaQuery.of(context).size.width < 600;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final content = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, isPhone ? 8 : 24, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle (bottom sheet only)
            if (isPhone)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: appBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

            // Title
            Text(
              widget.todo == null ? 'New todo' : 'Edit todo',
              style: GoogleFonts.fraunces(
                  fontSize: 22, fontWeight: FontWeight.w700, color: choc900),
            ),
            const SizedBox(height: 20),

            // Title field
            AppTextField(
              label: 'Title',
              controller: _title,
              hintText: 'What needs to be done?',
              errorText: _titleError,
              autofocus: widget.todo == null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description
            AppTextField(
              label: 'Description (optional)',
              controller: _desc,
              hintText: 'Add more details...',
              maxLines: 6,
              minLines: 2,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),

            // Due date + Category row
            if (!isPhone)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _dueDateSection()),
                  const SizedBox(width: 16),
                  Expanded(child: _categorySection(categories)),
                ],
              )
            else ...[
              _dueDateSection(),
              const SizedBox(height: 16),
              _categorySection(categories),
            ],

            const SizedBox(height: 16),

            // Tags
            _tagsSection(tags),

            // General error
            if (_generalError != null) ...[
              const SizedBox(height: 12),
              Text(_generalError!,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: appDanger)),
            ],

            const SizedBox(height: 24),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label:
                      widget.todo == null ? 'Add todo' : 'Save changes',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isPhone) return content;
    // Dialog mode: wrap in scrollable
    return content;
  }

  Widget _dueDateSection() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Due date',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: choc500)),
        const SizedBox(height: 6),
        // Quick chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _quickChip('Today', today),
            _quickChip('Tomorrow', tomorrow),
            _quickChip('Next week', nextWeek),
          ],
        ),
        const SizedBox(height: 8),
        // Field
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: choc500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _due == null ? 'Pick a date' : _formatDue(_due!),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _due == null ? appMuted : choc900,
                    ),
                  ),
                ),
                if (_due != null)
                  GestureDetector(
                    onTap: () => setState(() => _due = null),
                    child: const Icon(Icons.close, size: 16, color: appMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickChip(String label, DateTime date) {
    final selected = _due != null &&
        _due!.year == date.year &&
        _due!.month == date.month &&
        _due!.day == date.day;
    return GestureDetector(
      onTap: () => _setQuickDate(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? choc700 : appSurface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? choc700 : appBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 12,
              color: selected ? cream : choc500,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _categorySection(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: choc500)),
        const SizedBox(height: 6),
        _StyledDropdown(
          value: _categoryId,
          items: categories,
          onChanged: (v) => setState(() => _categoryId = v),
        ),
      ],
    );
  }

  Widget _tagsSection(List<Tag> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: choc500)),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) {
              final sel = _tagIds.contains(t.id);
              return GestureDetector(
                onTap: () => setState(() =>
                    sel ? _tagIds.remove(t.id) : _tagIds.add(t.id)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel ? choc700 : appSurface2,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: sel ? choc700 : appBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!sel)
                        Text('+ ',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: choc500)),
                      Text(
                        '#${t.name}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: sel ? cream : choc500,
                            fontWeight: FontWeight.w500),
                      ),
                      if (sel) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.close,
                            size: 12, color: cream),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 10),
        // New tag field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTag,
                onSubmitted: (_) => _addTag(),
                style: GoogleFonts.inter(fontSize: 14, color: choc900),
                decoration: const InputDecoration(
                  hintText: 'Create a new tag...',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _addTag,
              style: OutlinedButton.styleFrom(
                foregroundColor: choc700,
                side: const BorderSide(color: appBorder),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                minimumSize: const Size(0, 40),
              ),
              child: Text('Add',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom cream-styled dropdown for category selection.
class _StyledDropdown extends StatefulWidget {
  final int? value;
  final List<Category> items;
  final ValueChanged<int?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_StyledDropdown> createState() => _StyledDropdownState();
}

class _StyledDropdownState extends State<_StyledDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int?>(
        value: widget.value,
        dropdownColor: appSurface,
        borderRadius: BorderRadius.circular(10),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: choc500, size: 20),
        style: GoogleFonts.inter(fontSize: 14, color: choc900),
        items: [
          DropdownMenuItem<int?>(
            value: null,
            child: Text('None',
                style: GoogleFonts.inter(fontSize: 14, color: appMuted)),
          ),
          ...widget.items.map((c) => DropdownMenuItem<int?>(
                value: c.id,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: categoryColor(c.id),
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(c.name,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: choc900)),
                  ],
                ),
              )),
        ],
        onChanged: widget.onChanged,
        selectedItemBuilder: (_) => [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('None',
                style: GoogleFonts.inter(fontSize: 14, color: appMuted)),
          ),
          ...widget.items.map((c) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: appSurface,
                  border: Border.all(color: appBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: categoryColor(c.id),
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(c.name,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: choc900)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}