class Project {
  const Project({
    required this.id,
    required this.name,
    required this.color,
    required this.description,
  });

  final int id;
  final String name;
  final String color;
  final String? description;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#57b6ff',
      description: json['description'] as String?,
    );
  }
}
