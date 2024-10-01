import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';
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

enum ProgressStatus {
  planned,
  inProgress,
  completed,
}

extension ProgressStatusExtension on ProgressStatus {
  IconData get icon {
    switch (this) {
      case ProgressStatus.planned:
        return Icons.more_horiz;
      case ProgressStatus.inProgress:
        return Icons.play_arrow;
      case ProgressStatus.completed:
        return Icons.done;
    }
  }

  Color get color {
    switch (this) {
      case ProgressStatus.planned:
        return Colors.blue.shade400;
      case ProgressStatus.inProgress:
        return Colors.orange.shade400;
      case ProgressStatus.completed:
        return Colors.green.shade400;
    }
  }
}

class WeightGoalProgressSet {
  int reps = 0;
  double weight = 0;
  ProgressStatus status = ProgressStatus.planned;
  DateTime? endRestAt;
  bool isDone = false;

  WeightGoalProgressSet({
    this.reps = 0,
    this.weight = 0,
    this.status = ProgressStatus.planned,
  });

  WeightGoalProgressSet.fromJson(Map json) {
    reps = json['reps'];
    weight = json['weight'];
    status = ProgressStatus
        .values[json.getOrDefault('status', ProgressStatus.planned.index)];
    final endRestAtValue = json.getOrDefault('endRestAt', null);
    if (endRestAtValue != null) {
      endRestAt = DateTime.fromMillisecondsSinceEpoch(endRestAtValue);
    }
    isDone = json.getOrDefault('isDone', false);
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'status': status.index,
      'endRestAt': endRestAt?.millisecondsSinceEpoch,
      'isDone': isDone,
    };
  }
}

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

class CardioGoalProgress extends GoalProgress<CardioGoal> {
  ProgressStatus status = ProgressStatus.planned;
  CardioGoal actual = CardioGoal();
  DateTime? startAt;

  CardioGoalProgress.fromGoal(CardioGoal goal) : super(goal.clone()) {
    status = ProgressStatus.planned;
    actual = goal.clone()
      ..clear()
      ..duration = Duration.zero;
  }

  CardioGoalProgress.fromJson(Map json) : super.fromJson(json) {
    status = ProgressStatus
        .values[json.getOrDefault('status', ProgressStatus.planned.index)];
    actual = CardioGoal.fromJson(json['actual']);
    final startAtValue = json.getOrDefault('startAt', null);
    if (startAtValue != null) {
      startAt = DateTime.fromMillisecondsSinceEpoch(startAtValue);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'status': status.index,
      'actual': actual.toJson(),
      'startAt': startAt?.millisecondsSinceEpoch,
    };
  }
}
