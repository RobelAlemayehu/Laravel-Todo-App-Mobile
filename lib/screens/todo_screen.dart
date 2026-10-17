import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/todo.dart';
import '../providers.dart';
import '../services/api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_checkbox.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_toast.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/logo_mark.dart';
import '../widgets/progress_bar_thin.dart';
import '../widgets/segmented_filter.dart';
import '../widgets/skeleton_card.dart';
import 'categories_sidebar.dart';
import 'todo_form_sheet.dart';

// ── Grouping helpers ────────────────────────────────────────────────────────
enum _Group { overdue, today, upcoming, noDate, completed }

_Group _groupOf(Todo t) {
  if (t.isCompleted) return _Group.completed;
  if (t.dueDate == null) return _Group.noDate;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
  if (due.isBefore(today)) return _Group.overdue;
  if (due == today) return _Group.today;
  return _Group.upcoming;
}

String _relativeDue(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(due.year, due.month, due.day);
  final diff = d.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  if (diff < 0) return '${-diff} days overdue';
  if (diff <= 7) return 'In $diff days';
  return formatShortDate(due);
}

AppChipVariant _dueDateVariant(Todo t) {
  if (t.isCompleted) return AppChipVariant.success;
  if (t.dueDate == null) return AppChipVariant.neutral;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
  if (d.isBefore(today)) return AppChipVariant.overdue;
  if (d == today || d.difference(today).inDays <= 2) return AppChipVariant.dueSoon;
  return AppChipVariant.neutral;
}

// ── Main screen ──────────────────────────────────────────────────────────────
class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();

  List<Todo> _todos = [];
  int _nextPage = 1;
  bool _hasNext = true;
  bool _loading = false;
  int _request = 0;
  String? _error;

  // Filter state (0=All, 1=Active, 2=Done)
  int _filterIndex = 0;

  // True totals kept across filter changes
  int _totalAll = 0;
  int _totalActive = 0;
  int _totalDone = 0;

  // Current search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _load();
      }
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  bool? get _completed => switch (_filterIndex) {
        1 => false,
        2 => true,
        _ => null,
      };

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasNext)) return;

    final id = ++_request;
    final page = reset ? 1 : _nextPage;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ref.read(apiProvider).fetchTodos(
            page: page,
            completed: _completed,
          );
      if (!mounted || id != _request) return;
      setState(() {
        if (reset) _todos.clear();
        _todos.addAll(result.todos);
        _hasNext = result.hasNext;
        _nextPage = page + 1;
        _updateCounts();
      });
    } catch (e) {
      if (!mounted || id != _request) return;
      if (e is DioException && e.response?.statusCode == 401) {
        await _logout();
        return;
      }
      setState(() => _error = Api.errorMessage(e));
    } finally {
      if (mounted && id == _request) setState(() => _loading = false);
    }
  }

  /// Compute totals from currently loaded data plus filter-aware logic.
  void _updateCounts() {
    if (_completed == null) {
      // All tab: we have all types
      _totalAll = _todos.length;
      _totalActive = _todos.where((t) => !t.isCompleted).length;
      _totalDone = _todos.where((t) => t.isCompleted).length;
    } else if (_completed == false) {
      _totalActive = _todos.length;
    } else {
      _totalDone = _todos.length;
    }
    if (_completed == null) {
      _totalAll = _totalActive + _totalDone;
    } else {
      _totalAll = _totalActive + _totalDone;
    }
  }

  Future<void> _logout() async {
    await ref.read(apiProvider).logout();
    ref.invalidate(loggedInProvider);
  }

  Future<void> _confirmLogout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Log out?',
      message: "You'll need to sign in again to see your todos.",
      confirmLabel: 'Log out',
    );
    if (ok) await _logout();
  }

  // ── Toggle with Undo ──────────────────────────────────────────────────────
  Future<void> _toggle(Todo t) async {
    final newCompleted = !t.isCompleted;

    // Optimistic update
    final index = _todos.indexWhere((x) => x.id == t.id);
    if (index == -1) return;
    setState(() {
      _todos[index] = t.copyWith(isCompleted: newCompleted);
      _totalActive += newCompleted ? -1 : 1;
      _totalDone += newCompleted ? 1 : -1;
      _totalAll = _totalActive + _totalDone;
    });

    final msg = newCompleted
        ? 'Task marked as completed'
        : 'Task marked as active';
    final undoLabel = newCompleted
        ? 'Undo, marks the task as active again'
        : 'Undo, marks the task as completed again';

    if (mounted) {
      showUndoToast(
        context,
        msg,
        undoSemanticLabel: undoLabel,
        onUndo: () async {
          // Re-send the ORIGINAL state
          try {
            await ref.read(apiProvider).updateTodo(t.id, {
              'is_completed': t.isCompleted,
            });
            if (!mounted) return;
            final idx2 = _todos.indexWhere((x) => x.id == t.id);
            if (idx2 == -1) return;
            setState(() {
              _todos[idx2] = t; // restore original
              _totalActive += t.isCompleted ? -1 : 1;
              _totalDone += t.isCompleted ? 1 : -1;
              _totalAll = _totalActive + _totalDone;
            });
          } catch (e) {
            if (mounted) showAppToast(context, "Couldn't update. Try again.");
          }
        },
      );
    }

    // Actual API call
    try {
      await ref.read(apiProvider).updateTodo(t.id, {
        'is_completed': newCompleted,
      });
      ref.invalidate(categoriesProvider);
    } catch (e) {
      // Rollback
      if (!mounted) return;
      final idx = _todos.indexWhere((x) => x.id == t.id);
      if (idx != -1) {
        setState(() {
          _todos[idx] = t;
          _totalActive += t.isCompleted ? 1 : -1;
          _totalDone += t.isCompleted ? -1 : 1;
          _totalAll = _totalActive + _totalDone;
        });
      }
      if (mounted) showAppToast(context, "Couldn't update. Try again.");
    }
  }

  Future<void> _delete(Todo t) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete this todo?',
      message: '"${t.title}"\n\nThis can\'t be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (!ok) return;
    try {
      await ref.read(apiProvider).deleteTodo(t.id);
      setState(() {
        _todos.removeWhere((x) => x.id == t.id);
        if (t.isCompleted) {
          _totalDone = (_totalDone - 1).clamp(0, 9999);
        } else {
          _totalActive = (_totalActive - 1).clamp(0, 9999);
        }
        _totalAll = (_totalAll - 1).clamp(0, 9999);
      });
      ref.invalidate(categoriesProvider);
      if (mounted) showAppToast(context, 'Todo deleted');
    } catch (e) {
      if (mounted) showAppToast(context, Api.errorMessage(e));
    }
  }

  Future<void> _openForm({Todo? todo}) async {
    final saved = await openTodoForm(context, todo: todo);
    if (saved == true) {
      ref.invalidate(categoriesProvider);
      _load(reset: true);
      if (mounted) showAppToast(context, todo == null ? 'Todo added' : 'Todo updated');
    }
  }

  // ── Filtered list ─────────────────────────────────────────────────────────
  List<Todo> get _filtered {
    if (_searchQuery.isEmpty) return _todos;
    final q = _searchQuery.toLowerCase();
    return _todos.where((t) {
      return t.title.toLowerCase().contains(q) ||
          (t.description?.toLowerCase().contains(q) ?? false) ||
          (t.category?.name.toLowerCase().contains(q) ?? false) ||
          t.tags.any((tag) => tag.name.toLowerCase().contains(q));
    }).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userNameProvider).value ?? '';
    final initial = name.isNotEmpty ? name[0] : '?';
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: appBg,
      floatingActionButton: width < 600 ? _fab() : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main column
            Expanded(
              child: Column(
                children: [
                  _topBar(name, initial, width, isWide),
                  Expanded(
                    child: _buildBody(name, isWide, width),
                  ),
                ],
              ),
            ),
            // Sidebar (wide screens)
            if (isWide) const CategoriesSidebarPanel(),
          ],
        ),
      ),
    );
  }

  Widget _fab() => Semantics(
        label: 'New todo',
        child: FloatingActionButton(
          onPressed: () => _openForm(),
          backgroundColor: choc700,
          foregroundColor: cream,
          elevation: 4,
          tooltip: 'New todo',
          child: const Icon(Icons.add, size: 28),
        ),
      );

  // Top bar
  Widget _topBar(String name, String initial, double width, bool isWide) {
    final title = name.isEmpty ? 'My todos' : "${name}'s todos";
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: appSurface,
        border: Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        children: [
          const LogoMark(size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fraunces(
                  fontSize: 18, fontWeight: FontWeight.w700, color: choc900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Categories icon (phone / tablet)
          if (!isWide)
            Tooltip(
              message: 'Categories & Tags',
              child: IconButton(
                onPressed: () => showCategoriesSidebar(context),
                icon: const Icon(Icons.label_outline, color: choc500),
                iconSize: 22,
                splashRadius: 22,
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
          // New todo button (tablet / wide phone)
          if (width >= 600) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: Text('New todo',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: choc700,
                foregroundColor: cream,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                minimumSize: const Size(0, 40),
              ),
            ),
          ],
          const SizedBox(width: 8),
          AvatarCircle(initial: initial),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Log out',
            child: IconButton(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout, color: choc500),
              iconSize: 20,
              splashRadius: 20,
              constraints:
                  const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String name, bool isWide, double width) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final firstName = name.split(' ').first;

    final pct = _totalAll == 0 ? 0.0 : _totalDone / _totalAll;

    return CustomScrollView(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Greeting + stats ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName.isNotEmpty ? '$greeting, $firstName' : greeting,
                  style: GoogleFonts.fraunces(
                      fontSize: 26, fontWeight: FontWeight.w700, color: choc900),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalActive active · $_totalDone done · ${(pct * 100).round()}% completed',
                  style: GoogleFonts.inter(fontSize: 13, color: choc500),
                ),
                const SizedBox(height: 10),
                ProgressBarThin(value: pct),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ── Search + filter ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(fontSize: 14, color: choc900),
                  decoration: InputDecoration(
                    hintText: 'Search todos...',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: appMuted),
                    prefixIcon:
                        const Icon(Icons.search, color: appMuted, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: appMuted),
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _searchCtrl.clear();
                            }),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                // Segmented filter
                SegmentedFilter(
                  selectedIndex: _filterIndex,
                  allCount: _totalAll,
                  activeCount: _totalActive,
                  doneCount: _totalDone,
                  onChanged: (i) {
                    setState(() => _filterIndex = i);
                    _load(reset: true);
                  },
                ),
              ],
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────────────
        if (_error != null && _todos.isEmpty)
          SliverFillRemaining(child: _errorState())
        else if (_todos.isEmpty && _loading)
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => const SkeletonCard(),
                childCount: 5,
              ),
            ),
          )
        else
          _todoList(isWide),

        // Loading more indicator
        if (_hasNext && !_todos.isEmpty)
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: choc700, strokeWidth: 2),
                    ),
                  )
                : const SizedBox(height: 80), // FAB clearance
          ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: choc500),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: choc500)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => _load(reset: true),
              style: FilledButton.styleFrom(
                  backgroundColor: choc700, foregroundColor: cream),
              child: Text('Retry',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _todoList(bool isWide) {
    // Group the filtered list
    final displayed = _filtered;

    // Build grouped structure
    final Map<_Group, List<Todo>> groups = {};
    for (final t in displayed) {
      groups.putIfAbsent(_groupOf(t), () => []).add(t);
    }

    // Empty state
    if (groups.isEmpty && !_loading) {
      return SliverFillRemaining(
        child: _emptyState(),
      );
    }

    // Ordered sections
    final order = [
      _Group.overdue,
      _Group.today,
      _Group.upcoming,
      _Group.noDate,
      _Group.completed,
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            // Build a flat list of section headers + cards
            final items = <Widget>[];
            for (final g in order) {
              final list = groups[g] ?? [];
              if (list.isEmpty) continue;
              items.add(_sectionHeader(g, list.length));
              for (final t in list) {
                items.add(_todoCard(t));
                items.add(const SizedBox(height: 8));
              }
              items.add(const SizedBox(height: 8));
            }
            if (i >= items.length) return null;
            return items[i];
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(_Group group, int count) {
    final (label, color) = switch (group) {
      _Group.overdue => ('OVERDUE', appDanger),
      _Group.today => ('TODAY', choc700),
      _Group.upcoming => ('UPCOMING', choc500),
      _Group.noDate => ('NO DATE', appMuted),
      _Group.completed => ('COMPLETED', appSuccess),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Row(
        children: [
          Text(
            '$label  ($count)',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 1, color: color.withOpacity(0.25)),
          ),
        ],
      ),
    );
  }

  Widget _todoCard(Todo t) {
    final isDone = t.isCompleted;

    // Left bar color
    final barColor = switch (true) {
      _ when isDone => appSuccess,
      _ when t.isOverdue => appDanger,
      _ when (t.dueDate != null &&
          t.dueDate!.difference(DateTime.now()).inDays <= 2) =>
        appDueSoon,
      _ => appBorder,
    };

    return Opacity(
      opacity: isDone ? 0.62 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F4B2E1E),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 3px left status bar
                Container(width: 3, color: barColor),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: AppCheckbox(
                                value: t.isCompleted,
                                onChanged: (_) => _toggle(t),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title + description
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openForm(todo: t),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isDone
                                            ? appMuted
                                            : choc900,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: appMuted,
                                      ),
                                    ),
                                    if (t.description != null &&
                                        t.description!.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        t.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: choc500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            // Edit + Delete buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Tooltip(
                                  message: 'Edit',
                                  child: InkWell(
                                    onTap: () => _openForm(todo: t),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.all(9),
                                      child: Icon(
                                          Icons.edit_outlined,
                                          size: 17,
                                          color: choc500),
                                    ),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Delete',
                                  child: InkWell(
                                    onTap: () => _delete(t),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.all(9),
                                      child: Icon(Icons.delete_outline,
                                          size: 17, color: appMuted),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Chips row
                        Padding(
                          padding: const EdgeInsets.only(left: 34, top: 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Category
                              if (t.category != null)
                                AppCategoryChip(
                                  name: t.category!.name,
                                  dotColor:
                                      categoryColor(t.category!.id),
                                ),
                              // Due date
                              if (t.dueDate != null)
                                AppStatusChip(
                                  _relativeDue(t.dueDate!),
                                  variant: _dueDateVariant(t),
                                ),
                              // Tags
                              ...t.tags.map((tag) =>
                                  AppTagChip(tag.name)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    switch (_filterIndex) {
      case 1:
        return EmptyState(
          icon: Icons.check_circle_outline,
          title: "You're all caught up",
          subtitle: 'No active todos right now',
          actionLabel: 'Create a todo',
          onAction: () => _openForm(),
        );
      case 2:
        return EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing completed yet',
          subtitle: 'Mark a todo as done to see it here',
          actionLabel: 'View active tasks',
          onAction: () {
            setState(() => _filterIndex = 1);
            _load(reset: true);
          },
        );
      default:
        return EmptyState(
          icon: Icons.list_alt_outlined,
          title: 'No todos yet',
          subtitle: 'Create your first todo to get started',
          actionLabel: 'Create your first todo',
          onAction: () => _openForm(),
        );
    }
  }
}
