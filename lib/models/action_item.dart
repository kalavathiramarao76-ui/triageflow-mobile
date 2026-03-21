class ActionItem {
  final String id;
  final String title;
  final String description;
  final String type; // immediate, short-term, long-term
  final String escalationPath;
  final List<String> steps;
  final String priority;

  ActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.escalationPath,
    required this.steps,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'escalationPath': escalationPath,
        'steps': steps,
        'priority': priority,
      };

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: json['type'],
        escalationPath: json['escalationPath'],
        steps: List<String>.from(json['steps']),
        priority: json['priority'],
      );
}
