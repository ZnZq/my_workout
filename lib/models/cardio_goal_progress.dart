import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/utils.dart';

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
