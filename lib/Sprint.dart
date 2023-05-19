import 'package:suiviprojet/Task.dart';

class Sprint {
  int id;
  String nom;
  DateTime date_debut;
  DateTime date_fin;
  String description;
  String status;
  List<Task> tasks;

  Sprint({
    required this.id,
    required this.nom,
     required this.date_debut,
     required this.date_fin,
     required this.description,
    required this.status,
    required this.tasks,
  });

  factory Sprint.fromJson(Map<String, dynamic> json) {
    return Sprint(
      id: json['id'],
      nom: json['nom'],
      date_debut: DateTime.parse(json['date_debut']),
      date_fin: DateTime.parse(json['date_fin']),
      description: json['description'],
      status: json['status'],
      tasks: List<Task>.from(json['tasks'].map((task) => Task.fromJson(task))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'date_debut': date_debut.toIso8601String(),
      'date_fin': date_fin.toIso8601String(),
      'description': description,
      'status': status,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}
