import 'package:suiviprojet/User.dart';

class Task {
  User user;
  int id;
  String name;
  String description;
  String isCompleted;

  Task({
     this.id,
     this.name,
     this.description,
     this.isCompleted,
    this.user,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    User user;
    if (json['user'] != null) {
      user = User.fromJson(json['user']);
    }

    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user != null ? user.toJson() : null,
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

enum TaskStatus {
  todo,
  doing,
  done
}

