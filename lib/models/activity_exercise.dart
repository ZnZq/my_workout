import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/mixins/jsonable_mixin.dart';
import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/program_exercise.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress.dart';
import 'package:my_workout/utils.dart';

class ActivityExercise with EquatableMixin, JsonableMixin<ActivityExercise> {
  late final String id;

  String name = '';
  ExerciseExecuteMethod executeMethod = ExerciseExecuteMethod.weight;
  List<GoalProgress> goalProgress = [];

  ProgressStatus get status {
    return switch (executeMethod) {
      ExerciseExecuteMethod.weight => _getWeightStatus(),
      ExerciseExecuteMethod.cardio => _getCardioStatus(),
    };
  }

  ActivityExercise({
    required this.name,
    required this.executeMethod,
    required this.goalProgress,
    String? id,
  }) {
    this.id = id ?? uuid.v4();
  }

  ActivityExercise clone() {
    return ActivityExercise(
      id: id,
      name: name,
      executeMethod: executeMethod,
      goalProgress: goalProgress.map((e) => e.clone()).toList(),
    );
  }

  ActivityExercise.fromExercise(ProgramExercise exercise) {
    id = uuid.v4();
    name = exercise.name;
    executeMethod = exercise.executeMethod;
    goalProgress = exercise.goals.map((e) => GoalProgress.fromGoal(e)).toList();
  }

  @override
  factory ActivityExercise.fromJson(Map json) {
    final id = json['id'] ?? uuid.v4();
    final name = json['name'] as String;
    final executeMethod = ExerciseExecuteMethod.values[
        json.getOrDefault('executeMethod', ExerciseExecuteMethod.weight.index)];
    final goalProgress = (json['goalProgress'] as List<dynamic>)
        .map((e) => GoalProgressFactory.fromJson(e))
        .toList();

    return ActivityExercise(
      id: id,
      name: name,
      executeMethod: executeMethod,
      goalProgress: goalProgress,
    );
  }

  void actualizeSets() {
    for (var element in goalProgress) {
      if (element is WeightGoalProgress) {
        element.actualizeSets();
      }
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'executeMethod': executeMethod.index,
      'goalProgress': goalProgress.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, name, executeMethod, goalProgress];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityExercise) return false;

    return id == other.id &&
        name == other.name &&
        executeMethod == other.executeMethod &&
        listEquality.equals(goalProgress, other.goalProgress);
  }

  @override
  int get hashCode {
    return Object.hash(
        id, name, executeMethod, listEquality.hash(goalProgress));
  }

  ProgressStatus _getWeightStatus() {
    if (goalProgress.isEmpty ||
        goalProgress.every((element) =>
            element is WeightGoalProgress &&
            element.status == ProgressStatus.planned)) {
      return ProgressStatus.planned;
    }
    if (goalProgress.every((element) =>
        element is WeightGoalProgress &&
        element.status == ProgressStatus.completed)) {
      return ProgressStatus.completed;
    }

    return ProgressStatus.inProgress;
  }

  ProgressStatus _getCardioStatus() {
    if (goalProgress.isEmpty ||
        goalProgress.every((element) =>
            element is CardioGoalProgress &&
            element.status == ProgressStatus.planned)) {
      return ProgressStatus.planned;
    }
    if (goalProgress.every((element) =>
        element is CardioGoalProgress &&
        element.status == ProgressStatus.completed)) {
      return ProgressStatus.completed;
    }

    return ProgressStatus.inProgress;
  }
}
