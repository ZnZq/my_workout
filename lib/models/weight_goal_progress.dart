import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress_set.dart';
import 'package:my_workout/utils.dart';

class WeightGoalProgress extends GoalProgress<WeightGoal> {
  List<WeightGoalProgressSet> sets = [];
  List<WeightGoalProgressSet> get completedSets =>
      sets.where((e) => e.status == ProgressStatus.completed).toList();

  ProgressStatus get status {
    final completedSets = this.completedSets;
    if (completedSets.length == sets.length) {
      return ProgressStatus.completed;
    } else if (sets.any((s) => s.status != ProgressStatus.planned)) {
      return ProgressStatus.inProgress;
    } else {
      return ProgressStatus.planned;
    }
  }

  WeightGoalProgress.fromGoal(WeightGoal goal) : super(goal.clone()) {
    for (var i = 0; i < goal.sets; i++) {
      sets.add(WeightGoalProgressSet());
    }
  }

  WeightGoalProgress.fromJson(Map json) : super.fromJson(json) {
    sets = json
        .getOrDefault('sets', [])
        .map((e) => WeightGoalProgressSet.fromJson(e))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [super.props, sets];
}
