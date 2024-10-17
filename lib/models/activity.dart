import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/activity_exercise.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/mixins/reportable_mixin.dart';
import 'package:my_workout/utils.dart';

class Activity with EquatableMixin, ReportableMixin {
  late final String id;

  String title = '';
  DateTime date = DateTime.now();
  ProgressStatus status = ProgressStatus.planned;
  List<ActivityExercise> exercises = [];

  Activity({
    required this.title,
    required this.date,
    this.status = ProgressStatus.planned,
    this.exercises = const [],
    String? id,
  }) {
    this.id = id ?? uuid.v4();
  }

  Activity.fromProgram({required Program program}) {
    id = uuid.v4();
    title = program.title;
    date = DateTime.now();
    exercises =
        program.exercises.map((e) => ActivityExercise.fromExercise(e)).toList();
  }

  Activity.empty() {
    id = uuid.v4();
  }

  Activity.fromJson(Map json) {
    id = json['id'] ?? uuid.v4();
    title = json['title'] as String;
    date = DateTime.fromMillisecondsSinceEpoch(json['date'] as int);
    status = ProgressStatus
        .values[json.getOrDefault('status', ProgressStatus.planned.index)];
    exercises = (json['exercises'] as List<dynamic>)
        .map((e) => ActivityExercise.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'status': status.index,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('Activity: $title');
    buffer.writeln('Date: ${dateFormat.format(date)}');
    buffer.writeln('Status: ${status.name}');
    buffer.writeln('Exercises:');

    for (final exercisePair in exercises.indexed) {
      final exerciseIndex = exercisePair.$1 + 1;
      final exercise = exercisePair.$2;

      buffer.writeln(
          '$exerciseIndex. ${exercise.name}. ${exercise.status.name}:');
      for (final goalPair in exercise.goalProgress.indexed) {
        final goalIndex = goalPair.$1 + 1;
        final goal = goalPair.$2;

        final header = goal.generateReportHeader(goalIndex);
        buffer.writeln('    $header');
        final goalReport = goal.generateReport();
        for (final goalReportLine in goalReport) {
          buffer.writeln('        * $goalReportLine');
        }
      }
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [id, title, date, status, exercises];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Activity) return false;

    return id == other.id &&
        title == other.title &&
        status == other.status &&
        date == other.date &&
        listEquality.equals(exercises, other.exercises);
  }

  @override
  int get hashCode {
    return Object.hash(id, title, date, status, listEquality.hash(exercises));
  }
}
