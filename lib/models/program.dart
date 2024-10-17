import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/program_exercise.dart';
import 'package:my_workout/models/reportable.dart';

class Program with EquatableMixin, Reportable {
  late final String id;

  String title = '';
  String description = '';
  List<ProgramExercise> exercises = [];

  Program({
    required this.title,
    this.description = '',
    this.exercises = const [],
    String? id,
  }) {
    this.id = id ?? uuid.v4();
  }

  Program.empty() {
    id = uuid.v4();
  }

  Program.fromJson(Map json) {
    id = json['id'] ?? uuid.v4();
    title = json['title'] as String;
    description = json['description'] as String;
    exercises = (json['exercises'] as List<dynamic>)
        .map((e) => ProgramExercise.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('Program: $title');
    buffer.writeln('Description: $description');
    buffer.writeln('Exercises:');

    for (final pair in exercises.indexed) {
      final index = pair.$1 + 1;
      final exercise = pair.$2;
      buffer.writeln(exercise.generateReport(index));
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [id, title, description, exercises];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Program) return false;

    return id == other.id &&
        title == other.title &&
        description == other.description &&
        listEquality.equals(exercises, other.exercises);
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, listEquality.hash(exercises));
  }
}
