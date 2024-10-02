import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/weight_goal_progress.dart';
import 'package:my_workout/utils.dart';

class GoalProgressFactory {
  static GoalProgress fromJson(Map json) {
    if (!json.containsKey("__type")) {
      throw Exception('Invalid goal progress type');
    }

    final type = json['__type'] as String;
    switch (type) {
      case WeightGoalProgress.type:
        return WeightGoalProgress.fromJson(json);
      case CardioGoalProgress.type:
        return CardioGoalProgress.fromJson(json);
    }

    throw Exception('Invalid goal progress type');
  }
}

class GoalProgress<T extends Goal> with EquatableMixin {
  late final String id;

  late ExerciseExecuteMethod executeMethod;
  late T goal;

  GoalProgress(this.goal, {String? id}) {
    this.id = id ?? uuid.v4();
    executeMethod = goal.executeMethod;
  }

  static GoalProgress fromGoal(Goal goal) {
    if (goal is WeightGoal) {
      return WeightGoalProgress.fromGoal(goal);
    } else if (goal is CardioGoal) {
      return CardioGoalProgress.fromGoal(goal);
    } else {
      throw Exception('Unknown goal type');
    }
  }

  GoalProgress clone() {
    return GoalProgress(goal.clone() as T, id: id);
  }

  GoalProgress.fromJson(Map json) {
    id = json['id'] ?? uuid.v4();
    executeMethod = ExerciseExecuteMethod.values[
        json.getOrDefault('executeMethod', ExerciseExecuteMethod.weight.index)];
    goal = GoalFactory.fromJson(json['goal']) as T;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'executeMethod': executeMethod.index,
      'goal': goal.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, executeMethod, goal];
}
