class Tag {
  final int id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> j) => Tag(id: j['id'], name: j['name']);
}