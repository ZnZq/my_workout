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
  String generateReportHeader(int index) {
    final data = [
      if (actual.duration != null && goal.duration != null)
        'Duration: ${formatDuration(actual.duration!)}/${formatDuration(goal.duration!)}',
      if (actual.duration != null && goal.duration == null)
        'Duration: ${formatDuration(actual.duration!)}',
      if (actual.heartRate != null && goal.heartRate != null)
        'Heart Rate: ${actual.heartRate}/${goal.heartRate}',
      if (actual.heartRate != null && goal.heartRate == null)
        'Heart Rate: ${actual.heartRate}',
      if (actual.speed != null && goal.speed != null)
        'Speed: ${actual.speed!.toStringAsFixed(1)}/${goal.speed!.toStringAsFixed(1)}',
      if (actual.speed != null && goal.speed == null)
        'Speed: ${actual.speed!.toStringAsFixed(1)}',
      if (actual.distance != null && goal.distance != null)
        'Distance: ${actual.distance!.toStringAsFixed(1)}/${goal.distance!.toStringAsFixed(1)}',
      if (actual.distance != null && goal.distance == null)
        'Distance: ${actual.distance!.toStringAsFixed(1)}',
      if (actual.intensity != null && goal.intensity != null)
        'Intensity: ${actual.intensity!.toStringAsFixed(1)}/${goal.intensity!.toStringAsFixed(1)}',
      if (actual.intensity != null && goal.intensity == null)
        'Intensity: ${actual.intensity!.toStringAsFixed(1)}',
      if (actual.level != null && goal.level != null)
        'Level: ${actual.level!.toStringAsFixed(1)}/${goal.level!.toStringAsFixed(1)}',
      if (actual.level != null && goal.level == null)
        'Level: ${actual.level!.toStringAsFixed(1)}',
      if (actual.incline != null && goal.incline != null)
        'Incline: ${actual.incline!.toStringAsFixed(1)}/${goal.incline!.toStringAsFixed(1)}',
      if (actual.incline != null && goal.incline == null)
        'Incline: ${actual.incline!.toStringAsFixed(1)}',
    ];

    return '$index. ${data.join(', ')}';
  }

  @override
  List<String> generateReport() {
    return [];
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
