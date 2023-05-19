import 'dart:convert';

import 'package:flutter/material.dart';
import 'Activity.dart';
import 'Project.dart';
import 'package:http/http.dart' as http;



class activityScreen extends StatefulWidget {
  final Project project;

 activityScreen(this.project);

  @override
  _activityScreenState createState() => _activityScreenState();
}

class _activityScreenState extends State<activityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
                  padding: const EdgeInsets.all(16.0),
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
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Users: ${widget.project.users.map((user) => '${user.firstName} ${user.lastName}').join(", ")}',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
          Text(
            'les activity:',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.project.activitys.length,
              itemBuilder: (context, index) {
                final activity = widget.project.activitys[index];
                return ListTile(
                  title: Text(activity.name),
                  subtitle: Text(activity.description),
                  trailing:   SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () {
    _editactivity(activity);
  },
),IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                        showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this activity?'),
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
                        widget.project.activitys.remove(activity);
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
                  ),
        ]),),);
              },
            ),
          ),
        ],
      ),
     
    );
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
  void _editactivity(Activity activity) {
  _titleController.text = activity.name;
  _descriptionController.text = activity.description;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Edit activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            String title = _titleController.text;
            String description = _descriptionController.text;

            setState(() {
              activity.name = title;
              activity.description = description;
            });
            _saveP();

            _titleController.text = '';
            _descriptionController.text = '';

            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
      ],
    ),
  );
}

}
