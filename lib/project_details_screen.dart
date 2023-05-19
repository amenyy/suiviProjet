import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suiviprojet/BacklogButton.dart';
import 'package:suiviprojet/Project.dart';
import 'package:suiviprojet/Sprint.dart';
import 'package:suiviprojet/Task.dart';
import 'package:suiviprojet/User.dart';
import 'package:suiviprojet/UserService.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGlobalUsers();
  }
  Future<void> _saveP() async {
    String projectJson = jsonEncode(widget.project.toJson());

    final putResponse = await http.put(
      Uri.parse('http://localhost:3000/projects/${widget.project.id}'),
      headers: {'Content-Type': 'application/json'},
      body: projectJson,
    );

    if (putResponse.statusCode == 200) {
      print('Project updated');
    } else {
      print('Failed to update project');
    }
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
    final response = await http
        .get(Uri.parse('http://localhost:3000/projects/${widget.project.id}'));

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
        Uri.parse('http://localhost:3000/projects/${widget.project.id}'),
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

void _showForm() {
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String selectedStatus = 'Not Started';

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Create New Sprint'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _NameController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: selectedStartDate,
                firstDate: DateTime(2022),
                lastDate: DateTime(2100),
              ).then((selectedDate) {
                if (selectedDate != null) {
                  setState(() {
                    selectedStartDate = selectedDate;
                  });
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'Start Date: ${DateFormat.yMMMMd().format(selectedStartDate)}',
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: selectedEndDate,
                firstDate: DateTime(2022),
                lastDate: DateTime(2100),
              ).then((selectedDate) {
                if (selectedDate != null) {
                  setState(() {
                    selectedEndDate = selectedDate;
                  });
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'End Date: ${DateFormat.yMMMMd().format(selectedEndDate)}',
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: selectedStatus,
            onChanged: (newValue) {
              setState(() {
                selectedStatus = newValue;
              });
            },
            items: ['Not Started', 'Started'].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            String title = _NameController.text;
            String description = _descriptionController.text;

            Sprint newSprint = Sprint(
              id: 1, // Replace with the appropriate sprint ID
              nom: title,
              date_debut: selectedStartDate,
              date_fin: selectedEndDate,
              description: description,
              status: selectedStatus,
              tasks: [], // Initialize the tasks list
            );

            setState(() {
              widget.project.sprints.add(newSprint);
            });
            _saveP();

            _NameController.text = '';
            _descriptionController.text = '';

            Navigator.pop(context);
          },
          child: Text('Create'),
        ),
      ],
    ),
  );
}

 void editSprint(Sprint sprint) {
    TextEditingController _nameController =
        TextEditingController(text: sprint.nom);
    TextEditingController _descriptionController =
        TextEditingController(text: sprint.description);
    DateTime selectedStartDate = sprint.date_debut;
    DateTime selectedEndDate = sprint.date_fin;
    String selectedStatus = sprint.status;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Sprint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: selectedStartDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2100),
                ).then((selectedDate) {
                  if (selectedDate != null) {
                    setState(() {
                      selectedStartDate = selectedDate;
                    });
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Start Date: ${DateFormat.yMMMMd().format(selectedStartDate)}',
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: selectedEndDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2100),
                ).then((selectedDate) {
                  if (selectedDate != null) {
                    setState(() {
                      selectedEndDate = selectedDate;
                    });
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  'End Date: ${DateFormat.yMMMMd().format(selectedEndDate)}',
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (newValue) {
                setState(() {
                  selectedStatus = newValue;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'notstarted',
                  child: Text('Not Started'),
                ),
                DropdownMenuItem<String>(
                  value: 'started',
                  child: Text('Started'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              String title = _nameController.text;
              String description = _descriptionController.text;

              Sprint updatedSprint = Sprint(
                id: sprint.id,
                nom: title,
                date_debut: selectedStartDate,
                date_fin: selectedEndDate,
                description: description,
                status: selectedStatus,
                tasks: sprint.tasks,
              );

              setState(() {
                // Update the sprint in the project's list
                final index = widget.project.sprints.indexOf(sprint);
                if (index != -1) {
                  widget.project.sprints[index] = updatedSprint;
                }
              });
              _saveP();

              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
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
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 1.0, right: 6.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton.icon(
                          onPressed: _saveProject, // Save the project
                          icon: Icon(Icons.save),
                          label: Text('Project'),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF9B51E0),
                          ),
                        ),
                      ),
                    ),
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
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(87, 155, 81, 224),
                    ),
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
                widget.project.description ?? "no description to show ",
                style: TextStyle(
                  fontSize: 16,
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
                                  _showForm();// Handle adding a new sprint
                                },
                                
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: widget.project.sprints.length,
                                itemBuilder: (context, index) {
                                  Sprint sprint = widget.project.sprints[index];
                                  return ListTile(
                                    title: Text(sprint.nom),
                                    subtitle: Text(sprint.status),
                                    trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              editSprint(sprint);
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Edit'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this sprint?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            widget.project.sprints
                                                .remove(sprint);
                                          });
                                          _saveP();
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ])
                        
                                  );
                                },
                              ),
                            ),
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
