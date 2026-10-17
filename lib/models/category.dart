class Category {
  final int id;
  final String name;
  final int todosCount;

  Category({required this.id, required this.name, this.todosCount = 0});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id'],
        name: j['name'],
        todosCount: j['todos_count'] ?? 0,
      );
}