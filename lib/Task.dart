import 'package:suiviprojet/User.dart';

class Task {
  User? user; // Make user nullable by adding '?'
  int id;
  String name;
  String description;
  TaskStatus isCompleted;

  Task({
     required this.id,
     required this.name,
     required this.description,
     required this.isCompleted,
    this.user, // Update user to be nullable
  });

 factory Task.fromJson(Map<String, dynamic> json) {
  User? user; // Make user nullable by adding '?'
  if (json['user'] != null) {
    user = User.fromJson(json['user']);
  }

  return Task(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    isCompleted: TaskStatusExtension.fromString(json['isCompleted']),
    user: user,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'user': user != null ? user!.toJson() : null, // Add null check using '!'
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted.toString(),
    };
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
