class Task {
  int id;
  String name;
  String description;
  TaskStatus status;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.toString(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['nom'],
      description: json['description'],
      status: TaskStatusExtension.fromString(json['isCompleted']),
    );
  }
}

enum TaskStatus {
  pending,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  String _toString() {
    return this == TaskStatus.pending ? 'pending' : 'completed';
  }

  static TaskStatus fromString(String status) {
    return status.toLowerCase() == 'completed'
        ? TaskStatus.completed
        : TaskStatus.pending;
  }
}
