import 'package:flutter/material.dart';

import 'project.dart';
import 'project_details_screen.dart';
import 'project_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProjectList(),
    );
  }
}
