import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Sprint.dart';
import 'Task.dart';
import 'Project.dart';
import 'User.dart';

class SprintDetailsScreen extends StatefulWidget {
  final Sprint sprint;

  SprintDetailsScreen(this.sprint);

  @override
  _SprintDetailsScreenState createState() => _SprintDetailsScreenState();
}

class _SprintDetailsScreenState extends State<SprintDetailsScreen> {
  List<Task> todoList = [];
  List<Task> inProgressList = [];
  List<Task> doneList = [];

  @override
  void initState() {
    super.initState();
    fetchSprintTasks();
  }

  Future<void> fetchSprintTasks() async {
    for (var task in widget.sprint.tasks) {
      if (task.isCompleted == 'todo') {
        setState(() {
          todoList.add(task);
        });
      } else if (task.isCompleted == 'doing') {
        setState(() {
          inProgressList.add(task);
        });
      } else if (task.isCompleted == 'done') {
        setState(() {
          doneList.add(task);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sprint Details'),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sprint.nom,
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
                        'Created on: ${widget.sprint.date_debut}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                buildColumn('To Do', todoList),
                buildColumn('In Progress', inProgressList),
                buildColumn('Done', doneList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildColumn(String title, List<Task> tasks) {
    return Expanded(
      child: DragTarget<Task>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Draggable<Task>(
                        data: task,
                        child: Card(
                          child: ListTile(
                            title: Text(task.name),
                            subtitle: Text(task.description),
                          ),
                        ),
                        feedback: Card(
                          child: ListTile(
                            title: Text(task.name),
                            subtitle: Text(task.description),
                            tileColor: Colors.grey[300],
                          ),
                        ),
                        childWhenDragging: Container(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        onAccept: (data) {
          setState(() {
            if (title == 'To Do') {
              todoList.remove(data);
              data.isCompleted = 'todo';
              todoList.add(data);
            } else if (title == 'In Progress') {
              inProgressList.remove(data);
              data.isCompleted = 'doing';
              inProgressList.add(data);
            } else if (title == 'Done') {
              doneList.remove(data);
              data.isCompleted = 'done';
              doneList.add(data);
            }
            updateSprintTasksInJson();
          });
        },
        onLeave: (data) {
          setState(() {
            if (title == 'To Do') {
              todoList.remove(data);
            } else if (title == 'In Progress') {
              inProgressList.remove(data);
            } else if (title == 'Done') {
              doneList.remove(data);
            }
          });
        },
      ),
    );
  }

  void updateSprintTasksInJson() async {
    final jsonString = jsonEncode(widget.sprint.tasks);
    final file = File('C:/Users/bensa/OneDrive/Bureau/flutter suiviprojet mtir/suiviProjet/projects.json');
    await file.writeAsString(jsonString);
  }
}