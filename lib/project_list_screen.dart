import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suiviprojet/Project.dart';
import 'package:suiviprojet/project_details_screen.dart';
import 'package:suiviprojet/project_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurvedListItem extends StatelessWidget {
  const CurvedListItem({
     this.title,
     this.subtitle,
     this.time,
     this.color,
     this.nextColor,
     this.onTap,
     this.onDelete,
  });

  final Widget title;
  final Widget subtitle;
  final String time;
  final Color color;
  final Color nextColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, // uncomment this line to enable the onTap function
        child: Container(
          color: nextColor,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80.0),
                  topRight: Radius.circular(80.0)),
            ),
            padding: const EdgeInsets.only(
              left: 32,
              top: 35.0,
              bottom: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage('lib/images/avatar.png'),
                  radius: 35,
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        time,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: title,
                          ),
                          Row(
                            children: [
                              /*  IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.white,
                                onPressed: onEdit,
                              ),*/
                              SizedBox(width: 8.0),
                              IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.white,
                                onPressed: onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle,
                    ],
                  ),
                ),
              ],
            ),
          ),
          // onTap: onTap,
        ));
  }

  void onEdit() {}
}

class ProjectList extends StatefulWidget {
  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<dynamic> projects = [];
  String _searchQuery = '';

  final _projectService = ProjectService();
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Random random = Random();

  int _nextProjectId = 1;
  List<Color> colors = [
    Color(0xFF9B51E0),
    Color.fromARGB(87, 155, 81, 224),
    Colors.purple
  ];

  //add project func
  void _addProject() async {
       // DateTime selectedEndDate = .createdAt;

    final projectName = _projectNameController.text;
    final description = _descriptionController.text;

    final project = Project(
        id: _nextProjectId = random.nextInt(100),
        name: projectName,
        description: description,
        createdAt: DateTime.now(),

        //users: users,
        users: [],
        sprints: [],
        tasks: []);

    try {
      await _projectService.addProject(project);

      Map<String, dynamic> map = {};
      map['id'] = project.id;
      map['name'] = project.name;
      map['description'] = project.description;
          map['createdAt'] = project.createdAt.toString();

      map['users'] = project.users;

      _projectNameController.clear();
      _descriptionController.clear();
      setState(() {
        projects.add(map);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project added successfully'),
          backgroundColor: Colors.green, // Set the background color to green
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add project')),
      );
    }
  }

//deleteproj
  void _deleteProject(int projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      setState(() {
        projects.removeWhere((project) => project['id'] == projectId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project deleted successfully'),
          backgroundColor: Colors.red, // Set the background color to green
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete project')),
      );
    }
  }
//show add boxe

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Project'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Project Name'),
                  controller: _projectNameController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  controller: _descriptionController,
                ),
                // Add more fields as needed for your project model
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addProject();
                Navigator.of(context).pop();
                fetchProjects(); // Update project list after adding a project
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void fetchProjects() async {
    var url = 'http://localhost:3000/projects?q=$_searchQuery';

    try {
      var response = await http.get(Uri.parse(url));
      var responseData = jsonDecode(response.body);
      setState(() {
        projects = responseData;
      });
    } catch (error) {
      print('Error fetching projects: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Add the cover image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/images/bg.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.34,
              width: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            bottom: 370,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showAddProjectDialog,
              backgroundColor: Color.fromARGB(255, 45, 3, 61),
              child: Icon(Icons.add),
            ),
          ),

// Add the search bar
          Positioned(
            top: MediaQuery.of(context).size.height * 0.14,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Add the title
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1500),
                  opacity: _searchQuery.isNotEmpty ? 0 : 1,
                  child: Text(
                    'Project tracking',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.search, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search projects...',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            fetchProjects(); // Update project list when search query changes
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        

          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (BuildContext context, int index) {
                  final project = Project.fromJson(projects[index]);
                  return CurvedListItem(
                    title: Text(project.name),
                    subtitle: Text(project.description),
                    time: 'TODAY 5:30 PM',
                    color: colors[index % colors.length],
                    nextColor: Color.fromARGB(255, 255, 254, 254),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(project),
                        ),
                      );
                    },
                    onDelete: () {
                      _deleteProject(project.id);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
