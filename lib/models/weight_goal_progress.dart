import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress_set.dart';
import 'package:my_workout/utils.dart';

class WeightGoalProgress extends GoalProgress<WeightGoal> with EquatableMixin {
  static const type = 'WeightGoalProgress';

  List<WeightGoalProgressSet> sets = [];
  List<WeightGoalProgressSet> get completedSets =>
      sets.where((e) => e.status == ProgressStatus.completed).toList();

  ProgressStatus get status {
    final completedSets = this.completedSets;
    if (completedSets.length < goal.sets) {
      return ProgressStatus.inProgress;
    }
    if (completedSets.length == sets.length) {
      return ProgressStatus.completed;
    } else if (sets.any((s) => s.status != ProgressStatus.planned)) {
      return ProgressStatus.inProgress;
    } else {
      return ProgressStatus.planned;
    }
  }

  WeightGoalProgress({
    required WeightGoal goal,
    required this.sets,
    String? id,
  }) : super(goal, id: id);

  WeightGoalProgress.fromGoal(WeightGoal goal) : super(goal.clone()) {
    for (var i = 0; i < goal.sets; i++) {
      sets.add(WeightGoalProgressSet());
    }
  }

  WeightGoalProgress.fromJson(Map json) : super.fromJson(json) {
    sets = json
        .getOrDefault('sets', <dynamic>[])
        .map((e) => WeightGoalProgressSet.fromJson(e))
        .toList()
        .cast<WeightGoalProgressSet>();
  }

  @override
  GoalProgress<Goal> clone() {
    return WeightGoalProgress(
      goal: goal.clone(),
      sets: sets.map((e) => e.clone()).toList(),
      id: id,
    );
  }

  void actualizeSets() {
    sets.removeWhere((element) => element.status == ProgressStatus.planned);
    final toAdd = goal.sets - sets.length;
    for (var i = 0; i < toAdd; i++) {
      sets.add(WeightGoalProgressSet());
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      '__type': type,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [super.props, sets];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WeightGoalProgress) return false;

    return super == other && listEquality.equals(sets, other.sets);
  }

  @override
  int get hashCode {
    return Object.hash(super.hashCode, listEquality.hash(sets));
  }
}
