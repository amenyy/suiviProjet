import 'package:suiviprojet/User.dart';

class Project {
  int id;
  String name;
  String description;
  DateTime createdAt;
  List<User> users;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.users,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'users': users.map((user) => user.toJson()).toList(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    List<User> users = [];

    if (json['users'] != null && json['users'] is List<dynamic>) {
      users = (json['users'] as List<dynamic>).map((userJson) {
        if (userJson is Map<String, dynamic>) {
          return User.fromJson(userJson);
        } else {
          throw Exception('Invalid user format: $userJson');
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
    );
  }
}
