import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/utils.dart';

class CardioGoalProgress extends GoalProgress<CardioGoal> {
  static const type = 'CardioGoalProgress';

  ProgressStatus status = ProgressStatus.planned;
  CardioGoal actual = CardioGoal();
  DateTime? startAt;

  CardioGoalProgress({
    required CardioGoal goal,
    required this.status,
    required this.actual,
    this.startAt,
    String? id,
  }) : super(goal, id: id);

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
  CardioGoalProgress clone() {
    return CardioGoalProgress(
      goal: goal.clone(),
      status: status,
      actual: actual.clone(),
      startAt: startAt,
      id: id,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      '__type': type,
      'status': status.index,
      'actual': actual.toJson(),
      'startAt': startAt?.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [super.props, status, actual, startAt];
}
