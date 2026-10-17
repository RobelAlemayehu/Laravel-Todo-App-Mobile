import 'category.dart';
import 'tag.dart';

String formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
String formatDisplayDate(DateTime d) =>
    '${_months[d.month - 1]} ${d.day}, ${d.year}';

class Todo {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final Category? category;
  final List<Tag> tags;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.description,
    this.dueDate,
    this.category,
    this.tags = const [],
  });

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        isCompleted: j['is_completed'],
        dueDate: j['due_date'] != null ? DateTime.parse(j['due_date']) : null,
        category: j['category'] != null ? Category.fromJson(j['category']) : null,
        tags: (j['tags'] as List? ?? []).map((t) => Tag.fromJson(t)).toList(),
      );

  Todo copyWith({bool? isCompleted}) => Todo(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted ?? this.isCompleted,
        dueDate: dueDate,
        category: category,
        tags: tags,
      );

  String get dueText => dueDate == null ? '' : formatDate(dueDate!);

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }
}