import 'package:suiviprojet/User.dart';
import 'User.dart';

class Activity {
  int id;
  User user;
  String name;
  String description;

  Activity({
    this.id,
    this.user,
     this.name,
     this.description,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    User user;
    if (json['user'] != null) {
      user = User.fromJson(json['user']);
    }

    return Activity(
      id: json['id'],
      user: user,
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'user': user != null ? user.toJson() : null,
      'name': name,
      'description': description,
    };
  }
}
