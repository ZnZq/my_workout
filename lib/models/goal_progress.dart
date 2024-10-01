import 'package:equatable/equatable.dart';
import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress.dart';
import 'package:my_workout/utils.dart';

class GoalProgress<T extends Goal> with EquatableMixin {
  late ExerciseExecuteMethod executeMethod;
  late T goal;

  GoalProgress(this.goal) {
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

  GoalProgress.fromJson(Map json) {
    executeMethod = json['executeMethod'];
    goal = GoalFactory.fromJson(json['goal']) as T;
  }

  Map<String, dynamic> toJson() {
    return {
      'executeMethod': executeMethod,
      'goal': goal.toJson(),
    };
  }

  @override
  List<Object?> get props => [executeMethod, goal];
}
