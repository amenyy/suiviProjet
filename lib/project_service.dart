import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:suiviprojet/Project.dart';
import 'package:suiviprojet/User.dart';

class ProjectService {
  static const API_URL = 'http://192.168.1.21:3000/projects';

  Future<List<Project>> fetchProjects() async {
    final response = await http.get(Uri.parse(API_URL));

    if (response.statusCode == 200) {
      final projects = json.decode(response.body) as List<dynamic>;

      return projects
          .map((p) => Project(
                id: p['id'] as int,
                name: p['name'] as String,
                description: p['description'] as String,
                createdAt: DateTime.parse(p['createdAt'] as String),
                users: (p['users'] as List<dynamic>)
                    .map((userJson) => User.fromJson(userJson))
                    .toList(),
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch projects');
    }
  }

  Future<void> addProject(Project project) async {
    final projectJson = {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'createdAt': project.createdAt.toIso8601String(),
      'users': project.users.map((user) => user.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse(API_URL),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(projectJson),
    );

    if (response.statusCode == 201) {
      // Project added successfully
    } else {
      throw Exception('Failed to add project');
    }
  }
}
