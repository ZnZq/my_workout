import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress_set.dart';
import 'package:my_workout/utils.dart';

class WeightGoalProgressInfo {
  final int completedSets;
  final int totalSets;
  final double completedReps;
  final int totalReps;
  final double completedWeight;
  final double totalWeight;
  final double completedBy;

  WeightGoalProgressInfo({
    required this.completedSets,
    required this.totalSets,
    required this.completedReps,
    required this.totalReps,
    required this.completedWeight,
    required this.totalWeight,
    required this.completedBy,
  });
}

class WeightGoalProgress extends GoalProgress<WeightGoal> with EquatableMixin {
  static const type = 'WeightGoalProgress';

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

  WeightGoalProgressInfo getInfo() {
    final completeSets = completedSets;
    final completeRepsTotal =
        completeSets.map((e) => e.reps).fold(0.0, (a, b) => a + b);
    final completedWeightTotal =
        completeSets.map((e) => e.weight).fold(0.0, (a, b) => a + b);
    final completedWeightAvg = completedWeightTotal == 0
        ? 0.0
        : completedWeightTotal / completeSets.length;

    var completeRepsCount = completeRepsTotal / completeSets.length;
    if (completeRepsCount.isNaN) {
      completeRepsCount = 0;
    }

    final maxComplete =
        goal.sets * goal.reps * (goal.weight == 0 ? 1 : goal.weight);
    final currentComplete = completeSets.length *
        completeRepsCount *
        (goal.weight == 0 ? 1 : completedWeightAvg);

    return WeightGoalProgressInfo(
      completedSets: completeSets.length,
      totalSets: goal.sets,
      completedReps: completeRepsCount,
      totalReps: goal.reps,
      completedWeight: completedWeightAvg,
      totalWeight: goal.weight,
      completedBy: maxComplete == 0 ? 0 : currentComplete / maxComplete * 100,
    );
  }

  @override
  String generateReportHeader(int index) {
    final info = getInfo();
    final completeRepsCountStr =
        info.completedReps.toStringAsFixed(info.completedReps % 1 == 0 ? 0 : 1);
    final data = [
      'Sets: ${info.completedSets}/${info.totalSets}',
      'Reps: $completeRepsCountStr/${info.totalReps}',
      if (goal.weight != 0)
        'Weight: ${info.completedWeight.toStringAsFixed(1)}/${info.totalWeight.toStringAsFixed(1)}',
      'Goal completed by ${info.completedBy.toStringAsFixed(2)}%',
    ];

    return '$index. ${data.join(', ')}';
  }

  @override
  List<String> generateReport() {
    final list = <String>[];
    for (var i = 0; i < sets.length; i++) {
      final set = sets[i];
      if (set.status == ProgressStatus.planned) {
        continue;
      }

      if (set.reps != goal.reps || set.weight != goal.weight) {
        final data = [
          'Set ${i + 1}:',
          'Reps: ${set.reps}/${goal.reps}',
          if (goal.weight != 0) 'Weight: ${set.weight}/${goal.weight}',
        ];
        list.add(data.join(' '));
      }
    }

    return list;
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
