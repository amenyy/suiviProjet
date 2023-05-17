import 'package:suiviprojet/Sprint.dart';
import 'package:suiviprojet/Task.dart';
import 'package:suiviprojet/User.dart';

class Project {
  int id;
  String name;
  String description;
  DateTime createdAt;
  List<User> users;
  List<Sprint> sprints;
  List<Task> tasks;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.users,
    required this.sprints,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'users': users.map((user) => user.toJson()).toList(),
      'sprints': sprints.map((sprint) => sprint.toJson()).toList(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    List<User> users = [];
    List<Sprint> sprints = [];
    List<Task> tasks = [];

    if (json['users'] != null && json['users'] is List<dynamic>) {
      users = (json['users'] as List<dynamic>).map((userJson) {
        if (userJson is Map<String, dynamic>) {
          return User.fromJson(userJson);
        } else {
          throw Exception('Invalid user format: $userJson');
        }
      }).toList();
    }

    if (json['sprints'] != null && json['sprints'] is List<dynamic>) {
      sprints = (json['sprints'] as List<dynamic>).map((sprintJson) {
        if (sprintJson is Map<String, dynamic>) {
          return Sprint.fromJson(sprintJson);
        } else {
          throw Exception('Invalid sprint format: $sprintJson');
        }
      }).toList();
    }

    if (json['taches'] != null && json['taches'] is List<dynamic>) {
      tasks = (json['taches'] as List<dynamic>).map((taskJson) {
        if (taskJson is Map<String, dynamic>) {
          return Task.fromJson(taskJson);
        } else {
          throw Exception('Invalid task format: $taskJson');
        }
      }).toList();
    }

    DateTime? createdAt = DateTime.tryParse(json['createdAt'] ?? '');

    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: createdAt ?? DateTime.now(),
      users: users,
      sprints: sprints,
      tasks: tasks,
    );
  }
}
