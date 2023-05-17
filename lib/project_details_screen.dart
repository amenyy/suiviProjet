import 'dart:convert';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suiviprojet/BacklogButton.dart';
import 'package:suiviprojet/Project.dart';
import 'package:suiviprojet/Sprint.dart';
import 'package:suiviprojet/Task.dart';
import 'package:suiviprojet/User.dart';
import 'package:suiviprojet/UserService.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  ProjectDetailsScreen(this.project);

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final _userService = UserService();
  List<User> _selectedUsers = [];
  List<User> _globalUsers = [];
  List<User> _projectUsers = [];

  @override
  void initState() {
    super.initState();
    _loadGlobalUsers();
  }

  Future<void> _loadGlobalUsers() async {
    try {
      final users = await _userService.fetchUsers();
      setState(() {
        _globalUsers = users;
      });
    } catch (e) {
      print('Failed to load global users: $e');
    }
  }

  void _addUserToProject(User user) {
    setState(() {
      _selectedUsers.add(user);
    });
  }

  void _removeUserFromProject(User user) {
    setState(() {
      _selectedUsers.remove(user);
    });
  }

  void _openUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Users'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _globalUsers.length,
              itemBuilder: (BuildContext context, int index) {
                final user = _globalUsers[index];
                final isSelected = _selectedUsers.contains(user);

                return ListTile(
                  title: Text('${user.firstName} ${user.lastName}'),
                  trailing: IconButton(
                    icon: Icon(isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank),
                    onPressed: () {
                      if (isSelected) {
                        _removeUserFromProject(user);
                      } else {
                        _addUserToProject(user);
                      }
                      Navigator.pop(context); // Close the dialog
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProject() async {
    // Retrieve the existing project data
    final response = await http.get(
        Uri.parse('http://192.168.1.27:3000/projects/${widget.project.id}'));

    if (response.statusCode == 200) {
      // Parse the response body
      final jsonData = jsonDecode(response.body);

      // Retrieve the existing users, sprints, and tasks
      final existingUsers = (jsonData['users'] as List<dynamic>)
              ?.map((userJson) => User.fromJson(userJson))
              ?.toList() ??
          [];

      final existingSprints =
          (jsonData['sprints'] != null && jsonData['sprints'] is List<dynamic>)
              ? (jsonData['sprints'] as List<dynamic>)
                  .map((sprintJson) => Sprint.fromJson(sprintJson))
                  .toList()
              : [];

      final existingTasks =
          (jsonData['taches'] != null && jsonData['taches'] is List<dynamic>)
              ? (jsonData['taches'] as List<dynamic>)
                  .map((taskJson) => Task.fromJson(taskJson))
                  .toList()
              : [];

      // Create a new list of users with the selected users added
      final List<Map<String, dynamic>> updatedUsers = [
        ...existingUsers
            .map((user) => user.toJson()), // Convert existing users to JSON
        ..._selectedUsers
            .map((user) => user.toJson()), // Convert selected users to
      ];
      setState(() {
        _projectUsers = updatedUsers.cast<User>();
      });
      // Update the project with the new user IDs and users list
      final updatedProjectData = {
        ...jsonData,
        'users': updatedUsers,
        // Add other properties as needed
      };

      // Send the updated project data to the JSON server
      final putResponse = await http.put(
        Uri.parse('http://192.168.1.27:3000/projects/${widget.project.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedProjectData),
      );

      if (putResponse.statusCode == 200) {
        // Project updated successfully
        print('Project updated');
      } else {
        // Failed to update project
        print('Failed to update project');
      }
    } else {
      // Failed to retrieve project data
      print('Failed to retrieve project data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Stack(
            children: [
              Image.asset(
                'lib/images/avatar.png',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Created on: ${widget.project.createdAt}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Users: ${widget.project.users.map((user) => '${user.firstName}').join(", ")}',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openUserSelectionDialog(); // Ouvrir la boîte de dialogue de sélection d'utilisateur
                    },
                    icon: Icon(Icons.add),
                    label: Text('User'),
                  ),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(
                        0xFF9B51E0), // Utilisez la couleur lavande de votre choix
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.project.description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _saveProject, // Save the project
                  child: Text('Save Project'),
                ),
              ),
              Card(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(
                        0xFF9B51E0), // Utilisez la couleur lavande de votre choix
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Text(
                      'Backlog Project',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Task List'),
                              trailing: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  // Handle adding a new task
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.project.tasks.length,
                                itemBuilder: (context, index) {
                                  Task task = widget.project.tasks[index];
                                  return ListTile(
                                    title: Text(task.name),
                                    subtitle: Text(task.description),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Sprint List'),
                              trailing: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  // Handle adding a new sprint
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.project.sprints.length,
                                itemBuilder: (context, index) {
                                  Sprint sprint = widget.project.sprints[index];
                                  return ListTile(
                                    title: Text(sprint.name),
                                    subtitle: Text(sprint.endDate.toString()),
                                  );
                                },
                              ),
                            ),

                            /*  SizedBox(height: 16),
                  Text(
                    'Selected Users:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _selectedUsers.isNotEmpty
                      ? Column(
                          children: _selectedUsers.map((user) {
                            return ListTile(
                              title: Text('${user.firstName} ${user.lastName}'),
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle),
                                onPressed: () {
                                  _removeUserFromProject(user);
                                },
                              ),
                            );
                          }).toList(),
                        )
                      : Text(
                          'No users selected.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    ));
  }
}
