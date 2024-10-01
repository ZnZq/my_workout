import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/program_exercise.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress.dart';

class ActivityExercise {
  String name = '';
  ExerciseExecuteMethod executeMethod = ExerciseExecuteMethod.weight;
  List<GoalProgress> goalProgress = [];

  ProgressStatus get status {
    return switch (executeMethod) {
      ExerciseExecuteMethod.weight => _getWeightStatus(),
      ExerciseExecuteMethod.cardio => _getCardioStatus(),
    };
  }

  ActivityExercise.fromExercise(ProgramExercise exercise) {
    name = exercise.name;
    executeMethod = exercise.executeMethod;
    goalProgress = exercise.goals.map((e) => GoalProgress.fromGoal(e)).toList();
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
