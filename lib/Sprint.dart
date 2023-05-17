import 'package:suiviprojet/Task.dart';

class Sprint {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<Task> tasks;

  Sprint({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.tasks,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id'].toString(),
      name: json['nom'] ?? 'No Name',
      startDate: DateTime.parse(json['date_debut']),
      endDate: DateTime.parse(json['date_fin']),
      tasks: (json['taches'] as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  void removeTask(Task task) {
    tasks.remove(task);
  }
}
