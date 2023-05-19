import 'dart:convert';
import 'package:suiviprojet/User.dart';
import 'package:suiviprojet/Sprint.dart';
import 'package:suiviprojet/Task.dart';

class Project {
  int id;
  String name;
  String description;
  DateTime createdAt;
  List<Sprint> sprints;
  List<User> users;
  List<Task> tasks;

  Project({
     this.id,
     this.name,
     this.description,
     this.createdAt,
     this.sprints,
     this.users,
     this.tasks,
  });
  factory Project.fromJson(Map<String, dynamic> json) {
  List<dynamic> sprintsJson = json['sprints'];
  List<dynamic> usersJson = json['users'];
  List<dynamic> tasksJson = json['tasks'];

  List<User> users = usersJson.map((users) => User.fromJson(users)).toList();
  List<Task> tasks = tasksJson.map((tasks) => Task.fromJson(tasks)).toList();
  List<Sprint> sprints = sprintsJson.map((sprints) => Sprint.fromJson(sprints)).toList();

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
    sprints = (json['sprints'] as List<dynamic>).map((sprintsJson) {
      if (sprintsJson is Map<String, dynamic>) {
        return Sprint.fromJson(sprintsJson);
      } else {
        throw Exception('Invalid sprint format: $sprintsJson');
      }
    }).toList();
  }
  if (json['tasks'] != null && json['tasks'] is List<dynamic>) {
    tasks = (json['tasks'] as List<dynamic>).map((taskJson) {
      if (taskJson is Map<String, dynamic>) {
        return Task.fromJson(taskJson);
      } else {
        throw Exception('Invalid task format: $taskJson');
      }
    }).toList();
  }
  return Project(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    createdAt:DateTime.now(),
    sprints: sprints,
    users: users,
    tasks: tasks,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'sprints': sprints.map((sprint) => sprint.toJson()).toList(),
      'users': users.map((user) => user.toJson()).toList(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}
