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
     this.id,
     this.nom,
     this.date_debut,
     this.date_fin,
     this.description,
     this.status,
     this.tasks,
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
