class Task {
  final int id;
  final String title;
  final String deadline;
  final String priority;
  final bool done;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.priority,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'priority': priority,
      'done': done,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? deadline,
    String? priority,
    bool? done,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: (map['id'] as num).toInt(),
      title: map['title']?.toString() ?? '',
      deadline: map['deadline']?.toString() ?? '',
      priority: map['priority']?.toString() ?? '',
      done: map['done'] == true,
    );
  }
}
