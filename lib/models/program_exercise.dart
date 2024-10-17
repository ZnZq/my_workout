import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';

class ProgramExercise with EquatableMixin {
  late final String id;

  String name = '';
  ExerciseExecuteMethod executeMethod = ExerciseExecuteMethod.weight;
  List<Goal> goals = [];

  ProgramExercise({
    required this.name,
    required this.executeMethod,
    required this.goals,
    String? id,
  }) {
    this.id = id ?? uuid.v4();
  }

  ProgramExercise.empty() {
    id = uuid.v4();
  }

  ProgramExercise.fromJson(Map json) {
    id = json['id'] ?? uuid.v4();
    name = json['name'] as String;
    executeMethod = ExerciseExecuteMethod.values[json['executeMethod'] as int];
    goals = (json['goals'] as List<dynamic>)
        .map((e) => GoalFactory.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'executeMethod': executeMethod.index,
      'goals': goals.map((e) => e.toJson()).toList(),
    };
  }

  ProgramExercise clone() {
    return ProgramExercise(
      id: id,
      name: name,
      executeMethod: executeMethod,
      goals: goals.map((e) => e.clone()).toList(),
    );
  }

  String generateReport(int index) {
    final buffer = StringBuffer();
    buffer.writeln('$index. ${executeMethod.name}. $name. Goals:');
    for (final pair in goals.indexed) {
      final index = pair.$1 + 1;
      final goal = pair.$2;
      buffer.writeln('    ${goal.generateReport(index)}');
    }
    return buffer.toString().trim();
  }

  @override
  List<Object?> get props => [id, name, executeMethod, goals];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProgramExercise) return false;

    return id == other.id &&
        name == other.name &&
        executeMethod == other.executeMethod &&
        listEquality.equals(goals, other.goals);
  }

  @override
  int get hashCode {
    return Object.hash(id, name, executeMethod, listEquality.hash(goals));
  }
}
